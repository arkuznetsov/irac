// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем Элементы;            // - ОбъектыКластера   - элементы коллекции объектов кластера
Перем Лицензии;

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//   
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                  - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.РабочиеПроцессы);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);
	Лицензии = Новый Лицензии(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список рабочих процессов от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   
Процедура ОбновитьДанные(РежимОбновления = 0) Экспорт
	
	Если НЕ ТребуетсяОбновление(РежимОбновления) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения списка рабочих процессов кластера ""%1"",
		                        | КодВозврата = %2:%3%4",
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивПроцессов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивПроцессов.Добавить(Новый РабочийПроцесс(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивПроцессов);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(РежимОбновления = 0) Экспорт

	Возврат Элементы.ТребуетсяОбновление(РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Функция возвращает описание параметров объекта
//   
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список рабочих процессов
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора процессов (<поле>:<значение>)
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список рабочих процессов 1С
//
Функция Список(Отбор = Неопределено, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список рабочих процессов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка процессов, разделенные ","
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список рабочих процессов кластера 1С
//
Функция ИерархическийСписок(Знач ПоляИерархии, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество рабочих процессов в списке
//   
// Возвращаемое значение:
//    Число - количество рабочих процессов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание рабочего процесса кластера 1С
//   
// Параметры:
//   Процесс                 - Строка    - Рабочий процесс в виде <адрес сервера>:<номер процесса ОС (pid))>
//                                         или идентификатор рабочего процесса
//   РежимОбновления         - Число     - 1 - обновить данные принудительно (вызов RAC)
//                                         0 - обновить данные только по таймеру
//                                        -1 - не обновлять данные
//   КакСоответствие         - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание рабочего процесса кластера 1С
//
Функция Получить(Знач Процесс, Знач РежимОбновления = 0, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();

	Если Служебный.ЭтоGUID(Процесс) Тогда
		Отбор.Вставить("process", Процесс);
	Иначе
		Процесс = СтрРазделить(Процесс, ":", Ложь);
		Если Процесс.Количество() = 1 Тогда
			Процесс.Вставить(0, Кластер_Владелец.Получить("host"));
		КонецЕсли;

		Отбор.Вставить("host", СокрЛП(Процесс[0]));
		Отбор.Вставить("pid" , Число(СокрЛП(Процесс[1])));
	КонецЕсли;

	РабочиеПроцессы = Элементы.Список(Отбор, РежимОбновления, КакСоответствие);

	Если НЕ ЗначениеЗаполнено(РабочиеПроцессы) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РабочиеПроцессы[0];

КонецФункции // Получить()

// Функция возвращает список лицензий рабочих процессов 1С
//
// Возвращаемое значение:
//    ОбъектыКластера - список лицензий рабочих процессов 1С
//
Функция Лицензии() Экспорт
	
	Возврат Лицензии;
	
КонецФункции // Лицензии()
