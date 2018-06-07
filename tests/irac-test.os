﻿#Использовать "../src"
#Использовать "./fixtures"
#Использовать asserts
#Использовать fs
#Использовать tempfiles
#Использовать moskito

Перем ЮнитТест;
Перем ИспользоватьМок;
Перем АгентКластера;
Перем ИсполнительКоманд;
Перем ВременныйКаталог;

// Процедура выполняется после запуска теста
//
Процедура ПередЗапускомТеста() Экспорт
	
	АдресСервера = "localhost";
	ПортСервера = 1545;

	Если АгентКластера = Неопределено Тогда
		АгентКластера = Новый АдминистрированиеКластера(АдресСервера, ПортСервера, "");
	КонецЕсли;	

	Если ИсполнительКоманд = Неопределено Тогда
		ИспользоватьМок = Истина;

		ЭтоСерверСборок = ПолучитьПеременнуюСреды("CI");

		Сообщить(ВРег(ЭтоСерверСборок) = ВРег("true"));

		Если ИспользоватьМок Тогда
			ИсполнительКоманд = Мок.Получить(Новый ИсполнительКоманд(""));
		Иначе
			ИсполнительКоманд = Новый ИсполнительКоманд("8.3");
		КонецЕсли;	
	КонецЕсли;

	АгентКластера.УстановитьИсполнительКоманд(ИсполнительКоманд);
	
	Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
	Лог.УстановитьУровень(УровниЛога.Отладка);

КонецПроцедуры // ПередЗапускомТеста()

// Функция возвращает список тестов для выполнения
//
// Параметры:
//	Тестирование	- Тестер		- Объект Тестер (1testrunner)
//	
// Возвращаемое значение:
//	Массив		- Массив имен процедур-тестов
//	
Функция ПолучитьСписокТестов(Тестирование) Экспорт
	
	ЮнитТест = Тестирование;
	
	СписокТестов = Новый Массив;
	СписокТестов.Добавить("ТестДолжен_ПодключитьсяКСерверуАдминистрирования");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокАдминистраторов");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокКластеров");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокАдминистраторовКластера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокМенеджеров");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСерверовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыСервераКластера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокРабочихПроцессов");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыРабочегоПроцесса");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокЛицензийПроцесса");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСервисов");
	
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокБазНаСервере");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСокращенныеПараметрыБазыНаСервере");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПолныеПараметрыБазыНаСервере");
	СписокТестов.Добавить("ТестДолжен_ДобавитьИнформационнуюБазу");
	
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСеансовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьИерархическийСписокСеансовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыСеансаКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокЛицензийСеанса");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСоединенийКластера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокБлокировокКластера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыНазначенияФункциональностиСервера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокПрофилейБезопасностиКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыПрофиляБезопасностиКластера");

	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокКаталоговПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокCOMКлассовПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокКомпонентПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокМодулейПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокПриложенийПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля");

	Возврат СписокТестов;
	
КонецФункции // ПолучитьСписокТестов()

// Процедура выполняется после запуска теста
//
Процедура ПослеЗапускаТеста() Экспорт


КонецПроцедуры // ПослеЗапускаТеста()

// Процедура - тест
//
Процедура ТестДолжен_ПодключитьсяКСерверуАдминистрирования() Экспорт
	
	СтрокаПроверки = "localhost:1545";
	ДлинаСтроки = СтрДлина(СтрокаПроверки);

	Утверждения.ПроверитьРавенство(Лев(АгентКластера.ОписаниеПодключения(), ДлинаСтроки), СтрокаПроверки);

КонецПроцедуры // ТестДолжен_ПодключитьсяКСерверуАдминистрирования()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокАдминистраторов() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Администраторы.Список");
	
	АгентКластера.УстановитьАдминистратора("""mainadmin""", "123");

	Администраторы = АгентКластера.Администраторы();

	Утверждения.ПроверитьБольше(Администраторы.Количество(), 0, "Не удалось получить список администраторов");

КонецПроцедуры // ТестДолжен_ПолучитьСписокАдминистраторов()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКластеров() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();

	Утверждения.ПроверитьБольше(Кластеры.Количество(), 0, "Не удалось получить список кластеров");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКластеров()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Параметры");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	Имя = Кластер.Получить("Имя");
	Сервер = Кластер.Получить("Сервер");
	Порт = Кластер.Получить("Порт");
	РежимРаспределенияНагрузки = Кластер.Получить("РежимРаспределенияНагрузки");

	Утверждения.ПроверитьРавенство(Имя, """Локальный кластер""", "Ошибка проверки имени кластера");
	Утверждения.ПроверитьРавенство(Сервер, "Sport1", "Ошибка проверки сервера кластера");
	Утверждения.ПроверитьРавенство(Порт, "1541", "Ошибка проверки порта кластера");
	Утверждения.ПроверитьРавенство(РежимРаспределенияНагрузки
								, Перечисления.РежимыРаспределенияНагрузки.ПоПроизводительности
								, "Ошибка проверки режима распределения нагрузки кластера");
	
КонецПроцедуры // ТестДолжен_ПолучитьПараметрыКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокАдминистраторовКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Администраторы.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	Администраторы = Кластер.Администраторы();

	Утверждения.ПроверитьБольше(Администраторы.Количество(), 0, "Не удалось получить список администраторов кластера");

КонецПроцедуры // ТестДолжен_ПолучитьСписокАдминистраторовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокМенеджеров() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Менеджеры.Список");
	
	Менеджеры = Кластер.Менеджеры();

	Утверждения.ПроверитьБольше(Менеджеры.Количество(), 0, "Не удалось получить список менеджеров");

КонецПроцедуры // ТестДолжен_ПолучитьСписокМенеджеров()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСерверовКластера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Серверы.Список");
	
	Серверы = Кластер.Серверы();

	Утверждения.ПроверитьБольше(Серверы.Количество(), 0, "Не удалось получить список серверов кластера");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокСерверовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыСервераКластера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Серверы.Параметры");
	
	Серверы = Кластер.Серверы();

	Сервер = Серверы.Получить("""Центральный сервер""");

	Имя = Сервер.Получить("Имя");
	Хост = Сервер.Получить("СерверАгента");
	Порт = Сервер.Получить("ПортАгента");
	ДиапазонПортов = Сервер.Получить("ДиапазонПортов");

	Утверждения.ПроверитьРавенство(Имя, """Центральный сервер""", "Ошибка проверки имени сервера");
	Утверждения.ПроверитьРавенство(Хост, "Sport1", "Ошибка проверки сервера кластера");
	Утверждения.ПроверитьРавенство(Порт, "1540", "Ошибка проверки порта кластера");
	Утверждения.ПроверитьРавенство(ДиапазонПортов, "1560:1591", "Ошибка проверки диапазона портов сервера");
	
КонецПроцедуры // ТестДолжен_ПолучитьПараметрыСервераКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокРабочихПроцессов() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "РабочиеПроцессы.Список");
	
	Процессы = Кластер.РабочиеПроцессы();

	Утверждения.ПроверитьБольше(Процессы.Количество(), 0, "Не удалось получить список рабочих процессов");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокРабочихПроцессов()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыРабочегоПроцесса() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"РабочиеПроцессы.Список");
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"РабочиеПроцессы.Параметры");
	
	Процессы = Кластер.РабочиеПроцессы();

	Процесс = Процессы.Получить("Sport1:5428");

	АдресСервера = Процесс.Получить("АдресСервера");
	ИдПроцессаОС = Процесс.Получить("ИдПроцессаОС");
	КоличествоСоединений = Процесс.Получить("КоличествоСоединений");

	Утверждения.ПроверитьРавенство(АдресСервера, "Sport1", "Ошибка проверки адреса сервера рабочего процесса");
	Утверждения.ПроверитьРавенство(ИдПроцессаОС, "5428", "Ошибка проверки PID рабочего процесса");
	Утверждения.ПроверитьРавенство(КоличествоСоединений, "7", "Ошибка проверки количества соединений рабочего процесса");

КонецПроцедуры // ТестДолжен_ПолучитьПараметрыРабочегоПроцесса()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокЛицензийПроцесса() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"РабочиеПроцессы.Список");
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"РабочиеПроцессы.Параметры");
	
	Процессы = Кластер.РабочиеПроцессы();

	Процесс = Процессы.Получить("Sport1:5428");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"РабочиеПроцессы.Лицензии.Список");
	
	Лицензии = Процесс.Лицензии();

	Утверждения.ПроверитьБольше(Лицензии.Количество(), 0, "Не удалось получить список лицензий рабочего процесса");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокЛицензийПроцесса()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСервисов() Экспорт
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сервисы.Список");
	
	Сервисы = Кластер.Сервисы();

	Утверждения.ПроверитьБольше(Сервисы.Количество(), 0, "Не удалось получить список сервисов");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокСервисов()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокБазНаСервере() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Список");
	
	ИБ = Кластер.ИнформационныеБазы();
	
	Утверждения.ПроверитьБольше(ИБ.Количество(), 0, "Не удалось получить список информационных баз");

КонецПроцедуры // ТестДолжен_ПолучитьСписокБазНаСервере()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСокращенныеПараметрыБазыНаСервере() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Список");
	
	ИБ = Кластер.ИнформационныеБазы();
	
	АгентКластера.ИсполнительКоманд().Когда().КодВозврата().ТогдаВозвращает(0);
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.НедостаточноПрав");
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.СокращенныеПараметры");

	База = ИБ.Получить("DEV_User1_ACC_Cust1");

	Имя = База.Получить("Имя");
	Описание = База.Получить("Описание");
	ПолноеОписание = База.Получить("ПолноеОписание");

	Утверждения.ПроверитьРавенство(Имя, "DEV_User1_ACC_Cust1", "Ошибка проверки имени базы");
	Утверждения.ПроверитьРавенство(Описание, "", "Ошибка проверки описания базы");
	Утверждения.ПроверитьРавенство(ПолноеОписание, Ложь, "Ошибка проверки признака полного описания базы");
	
КонецПроцедуры // ТестДолжен_ПолучитьСокращенныеПараметрыБазыНаСервере()

// Процедура - тест
//
Процедура ТестДолжен_ДобавитьИнформационнуюБазу() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыИБ = Новый Структура();

	ПараметрыИБ.Вставить("ТипСУБД"								, Перечисления.ТипыСУБД.MSSQLServer);
	ПараметрыИБ.Вставить("АдресСервераСУБД"						, "localhost");
	ПараметрыИБ.Вставить("ИмяБазыСУБД"							, "DEV_User5_ACC_Cust3");
	ПараметрыИБ.Вставить("ИмяПользователяБазыСУБД"				, "_1CSrvUsr1");
	ПараметрыИБ.Вставить("ПарольПользователяБазыСУБД"			, "q2w3e4r5");
	ПараметрыИБ.Вставить("БлокировкаРегламентныхЗаданийВключена", Перечисления.СостоянияВыключателя.Выключено);
	ПараметрыИБ.Вставить("ВыдачаЛицензийСервером"				, Перечисления.ПраваДоступа.Разрешено);

	ИБ = Кластер.ИнформационныеБазы();
	ИБ.ОбновитьДанные(Истина);
	КоличествоИБ = ИБ.Количество();
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Добавить");
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.СписокПослеДобавления");
	
	ИБ.Добавить("DEV_User5_ACC_Cust3", , Истина, ПараметрыИБ);

	Утверждения.ПроверитьРавенство(ИБ.Количество() - КоличествоИБ, 1, "Ошибка проверки количества баз");

	База = ИБ.Получить("DEV_User5_ACC_Cust3");

	Имя = База.Получить("Имя");
	Описание = База.Получить("Описание");
	ПолноеОписание = База.Получить("ПолноеОписание");

	Утверждения.ПроверитьРавенство(Имя, "DEV_User5_ACC_Cust3", "Ошибка проверки имени базы");
	Утверждения.ПроверитьРавенство(Описание, "", "Ошибка проверки описания базы");
	Утверждения.ПроверитьРавенство(ПолноеОписание, Ложь, "Ошибка проверки признака полного описания базы");
	
КонецПроцедуры // ТестДолжен_ДобавитьИнформационнуюБазу()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПолныеПараметрыБазыНаСервере() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Список");
	
	ИБ = Кластер.ИнформационныеБазы();
	
	АгентКластера.ИсполнительКоманд().Когда().КодВозврата().ТогдаВозвращает(0);
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.ПолныеПараметры");

	База = ИБ.Получить("DEV_User1_ACC_Cust1");
	База.УстановитьАдминистратора("""Пользователь И. Б.""", "123");

	Имя = База.Получить("Имя", Истина);
	Описание = База.Получить("Описание");
	ПолноеОписание = База.Получить("ПолноеОписание");
	ТипСУБД	= База.Получить("ТипСУБД");
	ИмяБазыСУБД	= База.Получить("ИмяБазыСУБД");

	Утверждения.ПроверитьРавенство(Имя, "DEV_User1_ACC_Cust1", "Ошибка проверки имени базы");
	Утверждения.ПроверитьРавенство(Описание, "", "Ошибка проверки описания базы");
	Утверждения.ПроверитьРавенство(ПолноеОписание, Истина, "Ошибка проверки признака полного описания базы");
	Утверждения.ПроверитьРавенство(ТипСУБД, Перечисления.ТипыСУБД.MSSQLServer, "Ошибка проверки типа сервера СУБД");
	Утверждения.ПроверитьРавенство(ИмяБазыСУБД, "DEV_User1_ACC_Cust1", "Ошибка проверки имени базы на сервере СУБД");
	
КонецПроцедуры // ТестДолжен_ПолучитьПолныеПараметрыБазыНаСервере()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСеансовКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Список");
	
	Сеансы = Кластер.Сеансы();
	
	Утверждения.ПроверитьБольше(Сеансы.Количество(), 0, "Не удалось получить список сеансов");

КонецПроцедуры // ТестДолжен_ПолучитьСписокСеансовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьИерархическийСписокСеансовКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Список");
	
	Сеансы = Кластер.Сеансы().ИерархическийСписок("host,user-name");
	
	СеансыКомпьютера = Сеансы["Sport1"];

	Утверждения.ПроверитьБольше(СеансыКомпьютера.Количество(), 0, "Не удалось получить список сеансов");

КонецПроцедуры // ТестДолжен_ПолучитьИерархическийСписокСеансовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыСеансаКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Параметры");
	
	Сеансы = Кластер.Сеансы();
	
	Сеанс = Сеансы.Получить("DEV_User1_ACC_Cust1:1");

	Компьютер = Сеанс.Получить("Компьютер");
	Пользователь = Сеанс.Получить("Пользователь");
	Приложение = Сеанс.Получить("Приложение");

	Утверждения.ПроверитьРавенство(Компьютер, "Sport1", "Ошибка проверки компьютера сеанса");
	Утверждения.ПроверитьРавенство(Пользователь, "АКузнецов", "Ошибка проверки пользователя сеанса");
	Утверждения.ПроверитьРавенство(Приложение, "Designer", "Ошибка проверки типа приложения сеанса");

КонецПроцедуры // ТестДолжен_ПолучитьПараметрыСеансаКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокЛицензийСеанса() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Список");

	Сеансы = Кластер.Сеансы().Список();

	Для Каждого Сеанс Из Сеансы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Лицензии.Список");
	
		Лицензии = Сеанс.Лицензии();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Лицензии.Количество(), 0, "Не удалось получить список лицензий сеанса");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокЛицензийСеанса()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСоединенийКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Соединения.Список");
	
	Соединения = Кластер.Соединения();
	
	Утверждения.ПроверитьБольше(Соединения.Количество(), 0, "Не удалось получить список соединений");

КонецПроцедуры // ТестДолжен_ПолучитьСписокСоединенийКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокБлокировокКластера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Блокировки.Список");
	
	Блокировки = Кластер.Блокировки();
	
	Утверждения.ПроверитьБольше(Блокировки.Количество(), 0, "Не удалось получить список блокировок");

КонецПроцедуры // ТестДолжен_ПолучитьСписокБлокировокКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Серверы.Список");
	
	Серверы = Кластер.Серверы().Список();

	Для Каждого Сервер Из Серверы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"Серверы.Параметры");
	
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"НазначенияФункциональности.Список");
	
		НазначенияФункциональности = Сервер.НазначенияФункциональности();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(НазначенияФункциональности.Количество(),
								0,
								"Не удалось получить список назначений функциональности");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыНазначенияФункциональностиСервера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Серверы.Список");
	
	Серверы = Кластер.Серверы().Список();

	Для Каждого Сервер Из Серверы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"Серверы.Параметры");
	
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"НазначенияФункциональности.Параметры");
	
		НазначенияФункциональности = Сервер.НазначенияФункциональности().Список();
		Прервать;
	КонецЦикла;

	НазначениеФункциональности = НазначенияФункциональности[0];

	ИмяИБ = НазначениеФункциональности.Получить("ИмяИБ");
	ТипОбъекта = НазначениеФункциональности.Получить("ТипОбъекта");
	ТипНазначения = НазначениеФункциональности.Получить("ТипНазначения");

	Утверждения.ПроверитьРавенство(ИмяИБ, "DEV_User1_TRADE_Cust1", "Ошибка проверки имени ИБ назначения функциональности");
	Утверждения.ПроверитьРавенство(ТипОбъекта
								, """" + Перечисления.ОбъектыНазначенияФункциональности.КлиентскиеСоединения + """"
								, "Ошибка проверки типа объекта назначения функциональности");
	Утверждения.ПроверитьРавенство(ТипНазначения
								, Перечисления.ТипыНазначенияФункциональности.Назначать
								, "Ошибка проверки типа назначения функциональности");
	
КонецПроцедуры // ТестДолжен_ПолучитьПараметрыНазначенияФункциональностиСервера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокПрофилейБезопасностиКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности();
	
	Утверждения.ПроверитьБольше(Профили.Количество(), 0, "Не удалось получить список профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокПрофилейБезопасностиКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыПрофиляБезопасностиКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Параметры");
	
	Профили = Кластер.ПрофилиБезопасности();
	
	Профиль = Профили.Получить("ОсновнойПрофиль");

	Имя = Профиль.Получить("Имя");
	Каталоги = Профиль.Получить("Каталоги");
	Конфигуратор = Профиль.Получить("Конфигуратор");

	Утверждения.ПроверитьРавенство(Имя, "ОсновнойПрофиль", "Ошибка проверки имени профиля безопасности");
	Утверждения.ПроверитьРавенство(Каталоги
								, Перечисления.РежимыДоступа.Список
								, "Ошибка проверки режима доступа к каталогам");
	Утверждения.ПроверитьРавенство(Конфигуратор
								, Перечисления.ДаНет.Нет
								, "Ошибка проверки разрешения доступа к конфигуратору");

КонецПроцедуры // ТестДолжен_ПолучитьПараметрыПрофиляБезопасностиКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКаталоговПрофиля() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Каталоги.Список");
	
		Каталоги = Профиль.Каталоги();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Каталоги.Количество(),
								0,
								"Не удалось получить список каталогов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКаталоговПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокCOMКлассовПрофиля() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.COMКлассы.Список");
	
		COMКлассы = Профиль.COMКлассы();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(COMКлассы.Количество(),
								0,
								"Не удалось получить список COM-классов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокCOMКлассовПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКомпонентПрофиля() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Компоненты.Список");
	
		ВнешниеКомпоненты = Профиль.ВнешниеКомпоненты().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ВнешниеКомпоненты.Количество(),
								0,
								"Не удалось получить список внешних компонент профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКомпонентПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокМодулейПрофиля() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Модули.Список");
	
		ВнешниеМодули = Профиль.ВнешниеМодули();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ВнешниеМодули.Количество(),
								0,
								"Не удалось получить список внешних модулей профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокМодулейПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокПриложенийПрофиля() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Приложения.Список");
	
		Приложения = Профиль.Приложения();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Приложения.Количество(),
								0,
								"Не удалось получить список приложений профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокПриложенийПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры();
	
	Кластер = Кластеры.Получить("Sport1:1541");

	Кластер.УстановитьАдминистратора("""clusteradmin""", "123");

	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"ПрофилиБезопасности.Список");
	
	Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.ИнтернетРесурсы.Список");
	
		ИнтернетРесурсы = Профиль.ИнтернетРесурсы();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ИнтернетРесурсы.Количество(),
								0,
								"Не удалось получить список интернет ресурсов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля()

