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

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.СчетчикиРесурсов);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список счетчиков потребления ресурсов от утилиты администрирования кластера 1С
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
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");
	
	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения списка счетчиков ресурсов кластера ""%1"",
		                        | КодВозврата = %2:%3%4",
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивСчетчиков = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивСчетчиков.Добавить(Новый СчетчикРесурсов(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивСчетчиков);

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

// Функция возвращает список счетчиков потребления ресурсов кластера 1С
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора счетчиков потребления ресурсов (<поле>:<значение>)
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
//    Массив - список счетчиков потребления ресурсов кластера 1С
//
Функция Список(Отбор = Неопределено, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает счетчиков потребления ресурсов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка        - Поля для построения иерархии списка счетчиков потребления ресурсов,
//                                              разделенные ","
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
//    Соответствие - список счетчиков потребления ресурсов кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список счетчиков потребления ресурсов
//                                                                        или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество счетчиков потребления ресурсов в списке
//   
// Возвращаемое значение:
//    Число - количество счетчиков потребления ресурсов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание счетчика потребления ресурсов кластера 1С
//   
// Параметры:
//   ИмяИлиИд               - Строка    - Имя или идентификатор счетчика потребления ресурсов
//   РежимОбновления        - Число     - 1 - обновить данные принудительно (вызов RAC)
//                                        0 - обновить данные только по таймеру
//                                       -1 - не обновлять данные
//   КакСоответствие        - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание счетчика потребления ресурсов кластера 1С
//
Функция Получить(Знач ИмяИлиИд, Знач РежимОбновления = 0, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();

	Если Служебный.ЭтоGUID(ИмяИлиИд) Тогда
		Отбор.Вставить("counter", ИмяИлиИд);
	Иначе
		Отбор.Вставить("name", ИмяИлиИд);
	КонецЕсли;

	СписокСчетчиков = Элементы.Список(Отбор, РежимОбновления, КакСоответствие);
	
	Если НЕ ЗначениеЗаполнено(СписокСчетчиков) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокСчетчиков[0];

КонецФункции // Получить()

// Процедура добавляет новый счетчик потребления ресурсов в кластер 1С
//   
// Параметры:
//   Имя                 - Строка        - имя счетчика потребления ресурсов 1С
//   ПараметрыСчетчика   - Структура     - параметры счетчика потребления ресурсов 1С
//
Процедура Добавить(Имя, ПараметрыСчетчика = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСчетчика) = Тип("Структура") Тогда
		ПараметрыСчетчика = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя);

	Для Каждого ТекЭлемент Из ПараметрыСчетчика Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	Если ПараметрыКоманды["ДлительностьСбора"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("ДлительностьСбора", Перечисления.ВремяНакопленияСчетчиковРесурсов.ТекущийВызов);
	КонецЕсли;

	Если ПараметрыКоманды["Группировка"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("Группировка", Перечисления.ТипыГруппировкиСчетчиковРесурсов.Пользователи);
	КонецЕсли;

	Если ПараметрыКоманды["ТипОтбора"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("ТипОтбора", Перечисления.ТипыОтбораСчетчиковРесурсов.Все);
	КонецЕсли;

	Если ПараметрыКоманды["Отбор"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("Отбор", "");
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка добавления счетчика потребления ресурсов ""%1"" в кластере ""%2"",
		                        | КодВозврата = %3:%4%5",
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

// Процедура удаляет счетчик потребления ресурсов
//   
// Параметры:
//   Имя     - Строка   - Имя счетчика потребления ресурсов
//
Процедура Удалить(Знач Имя) Экспорт
	
	Если ТипЗнч(Имя) = Тип("Строка") Тогда
		Счетчик = Получить(Имя);
	КонецЕсли;

	Счетчик.Удалить();

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()
