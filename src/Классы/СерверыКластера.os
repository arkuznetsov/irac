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

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.Серверы);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список серверов кластера от утилиты администрирования кластера 1С
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
		ТекстОшибки = СтрШаблон("Ошибка получения списка серверов кластера ""%1"", КодВозврата = %2:%3%4",
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивСерверов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивСерверов.Добавить(Новый Сервер(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивСерверов);

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

// Функция возвращает список серверов кластера 1С
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора серверов (<поле>:<значение>)
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
//    Массив - список серверов кластера 1С
//
Функция Список(Отбор = Неопределено, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список серверов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка серверов, разделенные ","
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
//    Соответствие - список серверов кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список серверов или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество серверов в списке
//   
// Возвращаемое значение:
//    Число - количество серверов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание сервера кластера 1С
//   
// Параметры:
//   Сервер                 - Строка    - Адрес сервера в виде <сервер>:<порт>
//                                        или идентификатор сервера
//   РежимОбновления        - Число     - 1 - обновить данные принудительно (вызов RAC)
//                                        0 - обновить данные только по таймеру
//                                       -1 - не обновлять данные
//   КакСоответствие        - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание сервера кластера 1С
//
Функция Получить(Знач Сервер, Знач РежимОбновления = 0, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();

	Если Служебный.ЭтоGUID(Сервер) Тогда
		Отбор.Вставить("server", Сервер);
	Иначе
		МассивОтбора = СтрРазделить(Сервер, ":", Ложь);

		Отбор.Вставить("agent-host", СокрЛП(МассивОтбора[0]));

		Если МассивОтбора.Количество() = 1 Тогда
			Отбор.Вставить("agent-port", 1540);
		Иначе
			Отбор.Вставить("agent-port", Число(СокрЛП(МассивОтбора[1])));
		КонецЕсли;
	КонецЕсли;
	
	СписокСерверов = Элементы.Список(Отбор, РежимОбновления, КакСоответствие);
	
	Если НЕ ЗначениеЗаполнено(СписокСерверов) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокСерверов[0];

КонецФункции // Получить()

// Процедура добавляет новый сервер в кластер 1С
//   
// Параметры:
//   Имя                - Строка        - имя сервера 1С
//   АдресАгента        - Строка        - адрес сервера агента 1С
//   ПортАгента         - Число         - порт сервера агента 1С
//   ПараметрыСервера   - Структура     - параметры сервера 1С
//
Процедура Добавить(Имя, АдресАгента = "localhost", ПортАгента = 1541, ПараметрыСервера = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСервера) = Тип("Структура") Тогда
		ПараметрыСервера = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("Имя"                      , Служебный.ОбернутьВКавычки(Имя));
	ПараметрыКоманды.Вставить("АдресАгента"              , АдресАгента);
	ПараметрыКоманды.Вставить("ПортАгента"               , ПортАгента);

	Для Каждого ТекЭлемент Из ПараметрыСервера Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Добавить");

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка добавления сервера ""%1"" в кластер ""%2"", КодВозврата = %3:%4%5",
		                        Имя,
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Добавить()

// Процедура удаляет сервер из кластера 1С
//   
// Параметры:
//   СерверПорт            - Строка    - Адрес сервера в виде <сервер>:<порт>
//
Процедура Удалить(СерверПорт) Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"     , Получить(СерверПорт).Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Удалить");

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка добавления сервера ""%1"" в кластер ""%2"", КодВозврата = %3:%4%5",
		                        Получить(СерверПорт).Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()
