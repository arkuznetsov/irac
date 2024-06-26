// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Счетчик_Имя;
Перем Счетчик_Свойства;
Перем Счетчик_ДлительностьСбора;
Перем Счетчик_Значения;

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера
Перем ПараметрыЗначений;

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                  - ссылка на родительский объект кластера
//   Счетчик          - Строка, Соответствие     - имя счетчика потребления ресурсов в кластере 1С
//                                                 или параметры счетчика потребления ресурсов
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Счетчик)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Счетчик) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент    = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.СчетчикиРесурсов);

	Если ТипЗнч(Счетчик) = Тип("Соответствие") Тогда
		Счетчик_Имя = Счетчик["name"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Счетчик_Свойства, Счетчик);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Счетчик_Имя = Счетчик;
		МоментАктуальности = 0;
	КонецЕсли;
	
	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
	Счетчик_Значения = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
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
	
	ПараметрыКоманды.Вставить("ИмяСчетчика", Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения описания счетчика потребления ресурсов ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Счетчик_Свойства, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

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

	Возврат Служебный.ТребуетсяОбновление(Счетчик_Свойства, МоментАктуальности,
	                                      ПериодОбновления, РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Процедура получает значения счетчика потребления ресурсов
// и сохраняет в локальных переменных
//
// Параметры:
//    Отбор - отбор значений счетчика потребления ресурсов
//
Процедура ОбновитьДанныеЗначений(Знач Отбор = "") Экспорт

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя());
	Если ЗначениеЗаполнено(Отбор) Тогда
		ПараметрыКоманды.Вставить("Отбор"                , Отбор);
	КонецЕсли;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Значения");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		Если НЕ ЗначениеЗаполнено(Отбор) Тогда
			Отбор = "<без отбора>";
		КонецЕсли;
		ТекстОшибки = СтрШаблон("Ошибка получения значений счетчика потребления ресурсов ""%1""
		                        | с отбором ""%2"" в кластере ""%3"", КодВозврата = %4:%5%6",
		                        Имя(),
		                        Отбор,
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Счетчик_Значения.Заполнить(МассивРезультатов);

	Счетчик_Значения.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанныеЗначений()

// Функция возвращает описание параметров объекта
//
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает имя счетчика потребления ресурсов
//
// Возвращаемое значение:
//    Строка - имя счетчика потребления ресурсов
//
Функция Имя() Экспорт

	Возврат Счетчик_Имя;

КонецФункции // Имя()
	
// Функция возвращает значения счетчика потребления ресурсов
//
// Параметры:
//    Отбор - отбор значений счетчика потребления ресурсов
//
// Возвращаемое значение:
//    ОбъектыКластера - значения счетчика потребления ресурсов
//
Функция Значения(Знач Отбор = "") Экспорт
	
	Если Счетчик_Значения.ТребуетсяОбновление(ЗначениеЗаполнено(Отбор)) Тогда
		ОбновитьДанныеЗначений(Отбор);
	КонецЕсли;

	Возврат Счетчик_Значения;
	
КонецФункции // Значения()

// Функция возвращает значение параметра счетчика потребления ресурсов кластера 1С
//
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Произвольный - значение параметра счетчика потребления ресурсов кластера 1С
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти("ИМЯ, NAME", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Счетчик_Имя;
	ИначеЕсли НЕ Найти("ЗНАЧЕНИЯ, VALUES", ВРег(ИмяПоля)) = 0 Тогда
		Если РежимОбновления Тогда
			ОбновитьДанныеЗначений();
		КонецЕсли;
		ЗначениеПоля = Счетчик_Значения;
	Иначе
		ЗначениеПоля = Счетчик_Свойства.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Счетчик_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	
	КонецЕсли;

	Возврат ЗначениеПоля;
	
КонецФункции // Получить()

// Процедура изменяет параметры счетчика потребления ресурсов
//
// Параметры:
//   ПараметрыСчетчика         - Структура        - новые параметры счетчика потребления ресурсов
//
Процедура Изменить(Знач ПараметрыСчетчика = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСчетчика) = Тип("Соответствие") Тогда
		ПараметрыСчетчика = Новый Соответствие();
	КонецЕсли;
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя());
	
	Для Каждого ТекЭлемент Из ПараметрыСчетчика Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка изменения параметров счетчика потребления ресурсов ""%1""
		                        | в кластере ""%2"", КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Лог.Отладка(ВыводКоманды);
	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Изменить()

// Процедура удаляет счетчик потребления ресурсов из кластера 1С
//
Процедура Удалить() Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИмяСчетчика"                 , Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Отключить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка удаления счетчика потребления ресурсов ""%1""
		                        | в кластере ""%2"", КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(ВыводКоманды);

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()
