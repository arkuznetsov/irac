// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Сервер_Ид;    // server
Перем Сервер_Имя;    // name
Перем Сервер_АдресАгента;    // agent-host
Перем Сервер_ПортАгента;    // agent-port
Перем Сервер_Свойства;

Перем Сервер_НазначенияФункциональности;

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                  - ссылка на родительский объект кластера
//   Сервер           - Строка, Соответствие     - идентификатор сервера в кластере 1С или параметры сервера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Сервер)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Сервер) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.Серверы);

	Если ТипЗнч(Сервер) = Тип("Соответствие") Тогда
		Сервер_Ид = Сервер["server"];
		ЗаполнитьПараметрыСервера(Сервер);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Сервер_Ид = Сервер;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
	Сервер_НазначенияФункциональности = Новый НазначенияФункциональности(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);
	
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
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторСервера"        , Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения описания сервера ""%1"" списка профилей безопасности кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если НЕ ЗначениеЗаполнено(МассивРезультатов) Тогда
		Возврат;
	КонецЕсли;

	ЗаполнитьПараметрыСервера(МассивРезультатов[0]);

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

	Возврат Служебный.ТребуетсяОбновление(Сервер_Свойства, МоментАктуальности,
	                                      ПериодОбновления, РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Процедура заполняет параметры сервера кластера 1С
//
// Параметры:
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены параметры сервера
//
Процедура ЗаполнитьПараметрыСервера(ДанныеЗаполнения)

	Сервер_АдресАгента = ДанныеЗаполнения.Получить("agent-host");
	Сервер_ПортАгента = Число(ДанныеЗаполнения.Получить("agent-port"));
	Сервер_Имя = ДанныеЗаполнения.Получить("name");

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Сервер_Свойства, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыСервера()

// Функция возвращает описание параметров объекта
//
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает идентификатор сервера 1С
//
// Возвращаемое значение:
//    Строка - идентификатор сервера 1С
//
Функция Ид() Экспорт

	Возврат Сервер_Ид;

КонецФункции // Ид()

// Функция возвращает имя сервера 1С
//
// Возвращаемое значение:
//    Строка - имя сервера 1С
//
Функция Имя() Экспорт

	Если Служебный.ТребуетсяОбновление(Сервер_Имя, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Сервер_Имя;
	
КонецФункции // Имя()

// Функция возвращает адрес сервера 1С
//
// Возвращаемое значение:
//    Строка - адрес сервера 1С
//
Функция АдресСервера() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сервер_АдресАгента, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Сервер_АдресАгента;
	    
КонецФункции // АдресСервера()
	
// Функция возвращает порт сервера 1С
//
// Возвращаемое значение:
//    Строка - порт сервера 1С
//
Функция ПортСервера() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сервер_ПортАгента, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Сервер_ПортАгента;
	    
КонецФункции // ПортСервера()
	
// Функция возвращает список требований назначения функциональности сервера 1С
//
// Возвращаемое значение:
//    НазначенияФункциональности -  список требований назначения функциональности сервера 1С
//
Функция НазначенияФункциональности() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сервер_НазначенияФункциональности, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Сервер_НазначенияФункциональности;
	    
КонецФункции // НазначенияФункциональности()
	
// Функция возвращает значение параметра кластера 1С
//
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти("ИД, SERVER", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Сервер_Ид;
	ИначеЕсли НЕ Найти("ИМЯ, NAME", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Сервер_Имя;
	ИначеЕсли НЕ Найти("СЕРВЕРАГЕНТА, AGENT-HOST", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Сервер_АдресАгента;
	ИначеЕсли НЕ Найти("ПОРТАГЕНТА, AGENT-PORT", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Сервер_ПортАгента;
	ИначеЕсли НЕ Найти("ПРОФИЛИ, НАЗНАЧЕНИЯФУНКЦИОНАЛЬНОСТИ, ПРОФИЛИНАЗНАЧЕНИЯФУНКЦИОНАЛЬНОСТИ, PROFILES", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Сервер_НазначенияФункциональности;
	Иначе
		ЗначениеПоля = Сервер_Свойства.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Сервер_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	
	КонецЕсли;

	Возврат ЗначениеПоля;
	
КонецФункции // Получить()
	
// Процедура изменяет параметры сервера
//
// Параметры:
//   ПараметрыСервера         - Структура        - новые параметры сервера
//
Процедура Изменить(Знач ПараметрыСервера = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСервера) = Тип("Структура") Тогда
		ПараметрыСервера = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторСервера"        , Ид());
	
	Для Каждого ТекЭлемент Из ПараметрыСервера Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка изменения параметров сервера ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
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
