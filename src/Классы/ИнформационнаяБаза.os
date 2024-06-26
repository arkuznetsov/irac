// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем ИБ_Ид;                // (infobase) - идентификатор информационной базы
Перем ИБ_Имя;               // (name) - имя информационной базы
Перем ИБ_Описание;          // (descr) - краткое описание информационной базы
Перем ИБ_ПолноеОписание;    // Истина - получено полное описание; Ложь - сокращенное
Перем ИБ_ОшибкаАвторизации; // признак, что при попытке получения полных данных ИБ возникла ошибка авторизации
Перем ИБ_Сеансы;            // объект-список сеансов этой информационной базы
Перем ИБ_Соединения;        // объект-список соединений этой информационной базы
Перем ИБ_Блокировки;        // объект-список блокировок этой информационной базы
Перем ИБ_Свойства;          // значения свойств этого объекта-информационной базы

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера        // объект-агент управления кластером
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера     // объект-кластер, которому принадлежит текущая информационная база

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера     // параметры этого объекта управления информационной базой

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS     // период обновления данных (повторный вызов RAC)
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS   // последний момент времени обновления данных (время последнего вызова RAC)

Перем Лог;      // - Логирование     - объект-логгер                  // логгер

// Конструктор
//
// Параметры:
//   АгентКластера          - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер                - Кластер                  - ссылка на родительский объект кластера
//   ИБ                     - Строка, Соответствие     - идентификатор информационной базы в кластере
//                                                       или параметры информационной базы    
//   Администратор          - Строка                   - администратор информационной базы
//   ПарольАдминистратора   - Строка                   - пароль администратора информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ, Администратор = "", ПарольАдминистратора = "")

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(ИБ) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.ИнформационныеБазы);

	ИБ_ПолноеОписание = Ложь;

	Если ТипЗнч(ИБ) = Тип("Соответствие") Тогда
		ИБ_Ид = ИБ["infobase"];
		ЗаполнитьПараметрыИБ(ИБ);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		ИБ_Ид = ИБ;
		МоментАктуальности = 0;
	КонецЕсли;

	Если ЗначениеЗаполнено(Администратор) Тогда
		Кластер_Владелец.ДобавитьАдминистратораИБ(ИБ_Ид, Администратор, ПарольАдминистратора);
	КонецЕсли;
	
	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//
// Параметры:
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//
Процедура ОбновитьДанные(РежимОбновления = 0) Экспорт

	Если НЕ ТребуетсяОбновление(РежимОбновления) Тогда
		Возврат;
	КонецЕсли;

	ИБ_ОшибкаАвторизации = Ложь;

	ТекОписание = Неопределено;

	Если НЕ РежимОбновления = Перечисления.РежимыОбновленияДанных.ТолькоОсновные Тогда
		Попытка
			ТекОписание = ПолучитьПолноеОписаниеИБ();
		Исключение
			ТекОписание = Неопределено;
		КонецПопытки;
	КонецЕсли;

	Если ТекОписание = Неопределено Тогда
		ИБ_ПолноеОписание = Ложь;
		ТекОписание = ПолучитьОписаниеИБ();
	Иначе
		ИБ_ПолноеОписание = Истина;
	КонецЕсли;
	        
	Если ТекОписание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьПараметрыИБ(ТекОписание);

	ИБ_Сеансы = Новый Сеансы(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);
	ИБ_Соединения = Новый Соединения(Кластер_Агент, Кластер_Владелец, Неопределено, ЭтотОбъект);
	ИБ_Блокировки = Новый Блокировки(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Функция признак необходимости обновления данных
//
// Параметры:
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(РежимОбновления = 0) Экспорт

	Возврат Служебный.ТребуетсяОбновление(ИБ_Свойства, МоментАктуальности,
	                                      ПериодОбновления, РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Процедура заполняет параметры информационной базы
//
// Параметры:
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены параметры ИБ
//
Процедура ЗаполнитьПараметрыИБ(ДанныеЗаполнения)

	ИБ_Имя = ДанныеЗаполнения.Получить("name");
	ИБ_Описание = ДанныеЗаполнения.Получить("descr");

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, ИБ_Свойства, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыИБ()

// Функция возвращает описание параметров объекта
//
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает полное описание информационной базы 1С
//
// Возвращаемое значение:
//    Соответствие - полное описание информационной базы 1С
//
Функция ПолучитьПолноеОписаниеИБ()

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторИБ"             , Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииИБ"      , ПараметрыАвторизации());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);
	
	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("ПолноеОписание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		Если Найти(ВыводКоманды, "Недостаточно прав пользователя") = 0
		   И Найти(ВыводКоманды, "Превышено допустимое количество ошибок при вводе имени и пароля") = 0 Тогда
			ВызватьИсключение ВыводКоманды;
		Иначе
			ИБ_ОшибкаАвторизации = Истина;
			ТекстОшибки =  СтрШаблон("Ошибка получения полного описания информационной базы ""%1""
			                         | кластера ""%2"":%3%4",
			                         Имя(),
			                         Кластер_Владелец.Имя(),
			                         Символы.ПС,
			                         ВыводКоманды);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если НЕ ЗначениеЗаполнено(МассивРезультатов) Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат МассивРезультатов[0];

КонецФункции // ПолучитьПолноеОписаниеИБ()

// Функция возвращает сокращенное описание информационной базы 1С
//
// Возвращаемое значение:
//    Соответствие - сокращенное описание информационной базы 1С
//
Функция ПолучитьОписаниеИБ()

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторИБ"             , Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки =  СтрШаблон("Ошибка получения краткого описания информационной базы ""%1""
		                         | кластера ""%2"":%3%4",
		                         Имя(),
		                         Кластер_Владелец.Имя(),
		                         Символы.ПС,
		                         ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если НЕ ЗначениеЗаполнено(МассивРезультатов) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат МассивРезультатов[0];

КонецФункции // ПолучитьОписаниеИБ()

// Функция возвращает структуру параметров авторизации для информационной базы 1С
//
// Возвращаемое значение:
//    Строка - структура параметров авторизации для информационной базы 1С
//
Функция ПараметрыАвторизации() Экспорт
	
	Возврат Служебный.ПараметрыАвторизации(Перечисления.РежимыАдминистрирования.ИнформационныеБазы,
	                                       Кластер_Агент.ПолучитьАдминистратораИБ(Ид()));

КонецФункции // ПараметрыАвторизации()

// Функция возвращает строку параметров авторизации для информационной базы 1С
//
// Возвращаемое значение:
//    Строка - строка параметров авторизации для информационной базы 1С
//
Функция СтрокаАвторизации() Экспорт
	
	Возврат Служебный.СтрокаАвторизации(ПараметрыАвторизации());
	
КонецФункции // СтрокаАвторизации()

// Процедура устанавливает параметры авторизации для информационной базы 1С
//
// Параметры:
//   Администратор         - Строка    - администратор информационной базы 1С
//   Пароль                - Строка    - пароль администратора информационной базы 1С
//
Процедура УстановитьАдминистратора(Администратор, Пароль) Экспорт

	Кластер_Агент.ДобавитьАдминистратораИБ(Ид(), Администратор, Пароль);

КонецПроцедуры // УстановитьАдминистратора()

// Функция - возвращает параметры подключения к СУБД для информационной базы 1С
//
// Возвращаемое значение:
//   Структура         - параметры подключения к СУБД
//     * ТипСУБД            - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//     * Сервер             - Строка    - адрес сервера СУБД
//     * Пользователь       - Строка    - имя пользователя СУБД
//     * Пароль             - Строка    - пароль пользователя СУБД
//     * База               - Строка    - имя базы данных на сервере СУБД
//
Функция ПараметрыСУБД() Экспорт

	Возврат Кластер_Агент.ПараметрыСУБДИБ(Ид());

КонецФункции // ПараметрыСУБД()

// Процедура устанавливает параметры подключения к СУБД для информационной базы 1С
//
// Параметры:
//   ТипСУБД            - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//   Сервер             - Строка    - адрес сервера СУБД
//   Пользователь       - Строка    - имя пользователя СУБД
//   Пароль             - Строка    - пароль пользователя СУБД
//   База               - Строка    - имя базы данных на сервере СУБД
//
Процедура УстановитьПараметрыСУБД(ТипСУБД, Сервер, Пользователь, Пароль, Знач База = Неопределено) Экспорт

	Если НЕ ЗначениеЗаполнено(База) Тогда
		База = Имя();
	КонецЕсли;
	
	Кластер_Агент.ДобавитьПараметрыСУБДИБ(Ид(), ТипСУБД, Сервер, Пользователь, Пароль, База);

КонецПроцедуры // УстановитьПараметрыСУБД()

// Функция возвращает идентификатор информационной базы 1С
//
// Возвращаемое значение:
//    Строка - идентификатор информационной базы 1С
//
Функция Ид() Экспорт

	Возврат ИБ_Ид;

КонецФункции // Ид()

// Функция возвращает имя информационной базы 1С
//
// Возвращаемое значение:
//    Строка - имя информационной базы 1С
//
Функция Имя() Экспорт

	Возврат ИБ_Имя;
	
КонецФункции // Имя()

// Функция возвращает описание информационной базы 1С
//
// Возвращаемое значение:
//    Строка - описание информационной базы 1С
//
Функция Описание() Экспорт

	Возврат ИБ_Описание;
	
КонецФункции // Описание()

// Функция возвращает признак доступности полного описания информационной базы 1С
//
// Возвращаемое значение:
//    Булево - Истина - доступно полное описание; Ложь - доступно сокращенное описание
//
Функция ПолноеОписание() Экспорт

	Возврат (ИБ_ПолноеОписание = Истина);
	
КонецФункции // ПолноеОписание()

// Функция возвращает признак ошибки авторизации в ИБ при предыдущей попытке получения полных параметров
//
// Параметры:
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//
// Возвращаемое значение:
//    Булево - Истина - при предыдущей попытке получения полных параметров ИБ возникла ошибка авторизации
//
Функция ОшибкаАвторизации(РежимОбновления = 0) Экспорт

	ОбновитьДанные(РежимОбновления);

	Возврат (ИБ_ОшибкаАвторизации = Истина);
	
КонецФункции // ОшибкаАвторизации()

// Функция возвращает признак ошибки авторизации в ИБ при предыдущей попытке получения полных параметров
//
// Параметры:
//    НовоеЗначение    - Булево     - новое значение флага ошибки авторизации в ИБ
//
Процедура УстановитьОшибкуАвторизации(НовоеЗначение) Экспорт

	ИБ_ОшибкаАвторизации = НовоеЗначение;
	
КонецПроцедуры // УстановитьОшибкуАвторизации()

// Функция возвращает сеансы информационной базы 1С
//
// Возвращаемое значение:
//    Сеансы - сеансы информационной базы 1С
//
Функция Сеансы() Экспорт
	
	Если Служебный.ТребуетсяОбновление(ИБ_Сеансы, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат ИБ_Сеансы;
	    
КонецФункции // Сеансы()

// Функция возвращает соединения информационной базы 1С
//
// Возвращаемое значение:
//    Соединения - соединения информационной базы 1С
//
Функция Соединения() Экспорт
	
	Если Служебный.ТребуетсяОбновление(ИБ_Соединения, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат ИБ_Соединения;
	    
КонецФункции // Соединения()

// Функция возвращает блокировки информационной базы 1С
//
// Возвращаемое значение:
//    Блокировки - блокировки информационной базы 1С
//
Функция Блокировки() Экспорт
	
	Если Служебный.ТребуетсяОбновление(ИБ_Блокировки, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат ИБ_Блокировки;
	    
КонецФункции // Блокировки()

// Функция возвращает значение параметра информационной базы 1С
//
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра информационной базы
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти("ИД, INFOBASE", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_Ид;
	ИначеЕсли НЕ Найти("ИМЯ, NAME", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_Имя;
	ИначеЕсли НЕ Найти("ОПИСАНИЕ, DESCK", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_Описание;
	ИначеЕсли НЕ Найти("ПОЛНОЕОПИСАНИЕ", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_ПолноеОписание;
	ИначеЕсли НЕ Найти("СЕАНСЫ, SESSIONS", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_Сеансы;
	ИначеЕсли НЕ Найти("СОЕДИНЕНИЯ, CONNECTIONS", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_Соединения;
	ИначеЕсли НЕ Найти("БЛОКИРОВКИ, LOCKS", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ИБ_Блокировки;
	Иначе
		ЗначениеПоля = ИБ_Свойства.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = ИБ_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	
	КонецЕсли;

	Возврат ЗначениеПоля;
	
КонецФункции // Получить()
	
// Процедура изменяет параметры информационной базы
//
// Параметры:
//   ПараметрыИБ         - Структура        - новые параметры информационной базы
//
Процедура Изменить(Знач ПараметрыИБ = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторИБ"            , Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииИБ"     , ПараметрыАвторизации());

	Для Каждого ТекЭлемент Из ПараметрыИБ Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки =  СтрШаблон("Ошибка изменения информационной базы ""%1""
		                         | кластера ""%2"":%3%4",
		                         Имя(),
		                         Кластер_Владелец.Имя(),
		                         Символы.ПС,
		                         ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(ВыводКоманды);

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Изменить()

// Процедура удаляет информационную базу
//
// Параметры:
//   ДействияСБазойСУБД    - Строка      - "drop" - удалить базу данных; "clear" - очистить базу данных;
//                                         иначе оставить базу данных как есть
//
Процедура Удалить(ДействияСБазойСУБД = "") Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторИБ"             , Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииИБ"      , ПараметрыАвторизации());

	Если ДействияСБазойСУБД = Перечисления.ДействияСБазойСУБДПриУдалении.Очистить Тогда
		ПараметрыКоманды.Вставить("ОчиститьБД", Истина);
	КонецЕсли;
	Если ДействияСБазойСУБД = Перечисления.ДействияСБазойСУБДПриУдалении.Удалить Тогда
		ПараметрыКоманды.Вставить("УдалитьБД", Истина);
	КонецЕсли;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Удалить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки =  СтрШаблон("Ошибка удаления информационной базы ""%1""
		                         | кластера ""%2"":%3%4",
		                         Имя(),
		                         Кластер_Владелец.Имя(),
		                         Символы.ПС,
		                         ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Лог.Отладка(ВыводКоманды);

КонецПроцедуры // Удалить()
