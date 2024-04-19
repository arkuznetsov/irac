// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Процесс_Ид;            // process
Перем Процесс_АдресСервера;    // host
Перем Процесс_ПортСервера;    // port
Перем Процесс_Свойства;
Перем Процесс_Лицензии;

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера
Перем Процесс_Соединения;

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластера                 - ссылка на родительский объект кластера
//   Процесс          - Строка, Соответствие     - идентификатор рабочего процесса или параметры процесса
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Процесс)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Процесс) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.РабочиеПроцессы);

	Если ТипЗнч(Процесс) = Тип("Соответствие") Тогда
		Процесс_Ид = Процесс["process"];
		ЗаполнитьПараметрыПроцесса(Процесс);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Процесс_Ид = Процесс;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
	Процесс_Соединения      = Новый Соединения(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);
	Процесс_Лицензии        = Новый Лицензии(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);

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
	ПараметрыКоманды.Вставить("ИдентификаторПроцесса"       , Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		Лог.Предупреждение("Ошибка получения описания рабочего процесса ""%1:%2"" кластера ""%3"",
		                   | КодВозврата = %4:%5%6",
		                   АдресСервера(),
		                   ПортСервера(),
		                   Кластер_Владелец.Имя(),
		                   КодВозврата,
		                   Символы.ПС,
		                   ВыводКоманды);
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если НЕ ЗначениеЗаполнено(МассивРезультатов) Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьПараметрыПроцесса(МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанныеПроцесса()

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

	Возврат Служебный.ТребуетсяОбновление(Процесс_Свойства, МоментАктуальности,
	                                      ПериодОбновления, РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Процедура заполняет параметры рабочего процесса кластера 1С
//
// Параметры:
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены параметры рабочего процесса
//
Процедура ЗаполнитьПараметрыПроцесса(ДанныеЗаполнения)

	Процесс_АдресСервера = ДанныеЗаполнения.Получить("host");
	Процесс_ПортСервера = Число(ДанныеЗаполнения.Получить("port"));

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Процесс_Свойства, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыПроцесса()

// Функция возвращает описание параметров объекта
//
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает идентификатор рабочего процесса 1С
//
// Возвращаемое значение:
//    Строка - идентификатор рабочего процесса 1С
//
Функция Ид() Экспорт

	Возврат Процесс_Ид;

КонецФункции // Ид()

// Функция возвращает адрес сервера рабочего процесса 1С
//
// Возвращаемое значение:
//    Строка - адрес сервера рабочего процесса 1С
//
Функция АдресСервера() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Процесс_АдресСервера, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Процесс_АдресСервера;
	    
КонецФункции // АдресСервера()
	
// Функция возвращает порт рабочего процесса 1С
//
// Возвращаемое значение:
//    Строка - порт рабочего процесса 1С
//
Функция ПортСервера() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Процесс_ПортСервера, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Процесс_ПортСервера;
	    
КонецФункции // ПортСервера()
	
// Функция возвращает значение параметра рабочего процесса 1С
//
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра рабочего процесса
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Произвольный - значение параметра рабочего процесса 1С
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти("ИД, PROCESS", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Процесс_Ид;
	ИначеЕсли НЕ Найти("АДРЕССЕРВЕРА, HOST", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Процесс_АдресСервера;
	ИначеЕсли НЕ Найти("ПОРТСЕРВЕРА, PORT", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Процесс_ПортСервера;
	ИначеЕсли НЕ Найти("ЛИЦЕНЗИИ, LICENSES", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Лицензии(РежимОбновления);
	ИначеЕсли НЕ Найти("СОЕДИНЕНИЯ, CONNECTIONS", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Процесс_Соединения;
	Иначе
		ЗначениеПоля = Процесс_Свойства.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Процесс_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
	
// Функция возвращает список соединений рабочего процесса 1С
//
// Возвращаемое значение:
//    Соединения - список соединений рабочего процесса 1С
//
Функция Соединения() Экспорт
	
	Возврат Процесс_Соединения;
	
КонецФункции // Соединения()
	
// Функция возвращает список лицензий, выданных рабочим процессом 1С
//
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    ОбъектыКластера - список лицензий, выданных рабочим процессом 1С
//
Функция Лицензии(РежимОбновления = 0) Экспорт
	
	Если РежимОбновления Тогда
		Процесс_Лицензии.ОбновитьДанные(РежимОбновления);
	КонецЕсли;

	Возврат Процесс_Лицензии;
	
КонецФункции // Лицензии()
