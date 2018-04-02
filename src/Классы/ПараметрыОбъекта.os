// Класс хранящий структуру параметров объекта указанного типа
// Доступны типы:
//		cluster			- Кластер
//		admin			- Администратор (агента / кластера)
//		lock			- Блокировка
//		infobase		- ИнформационнаяБаза
//		manager			- МенеджерКластера
//		process			- РабочийПроцесс
//		server			- Сервер
//		service			- Сервис
//		session			- Сеанс
//		connection		- Соединение
//		process-license	- ЛицензияПроцесса
//		session-license	- ЛицензияСеанса
//		rule			- ТребованиеНазначения
//		profile			- ПрофильБезопасности

Перем Параметры;

Перем Лог;

// Конструктор
//   
// Параметры:
//   ИмяТипаОбъекта			- Строка	- имя типа объекта для которого создается структура параметров
//
Процедура ПриСозданииОбъекта(ИмяТипаОбъекта)

	Если НЕ Найти(ВРег("cluster, Кластер"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыКластера();
	ИначеЕсли НЕ Найти(ВРег("admin, Администратор"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыАдминистратора();
	ИначеЕсли НЕ Найти(ВРег("lock, Блокировка"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыБлокировки();
	ИначеЕсли НЕ Найти(ВРег("infobase, ИнформационнаяБаза"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыИнформационнойБазы();
	ИначеЕсли НЕ Найти(ВРег("manager, МенеджерКластера"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыМенеджераКластера();
	ИначеЕсли НЕ Найти(ВРег("process, РабочийПроцесс"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыРабочегоПроцесса();
	ИначеЕсли НЕ Найти(ВРег("server, Сервер"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыСервера();
	ИначеЕсли НЕ Найти(ВРег("service, Сервис"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыСервиса();
	ИначеЕсли НЕ Найти(ВРег("session, Сеанс"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыСеанса();
	ИначеЕсли НЕ Найти(ВРег("connection, Соединение"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыСоединения();
	ИначеЕсли НЕ Найти(ВРег("process-license, ЛицензияПроцесса"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыЛицензииПроцесса();
	ИначеЕсли НЕ Найти(ВРег("session-license, ЛицензияСеанса"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыЛицензииСеанса();
	ИначеЕсли НЕ Найти(ВРег("rule, ТребованиеНазначения"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыТребованияНазначения();
	ИначеЕсли НЕ Найти(ВРег("profile, ПрофильБезопасности"), ВРег(ИмяТипаОбъекта)) = 0 Тогда
		ЗаполнитьПараметрыПрофиляБезопасности();
	КонецЕсли;

КонецПроцедуры // ПриСозданииОбъекта()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция Получить(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураПараметров = Новый Соответствие();

	Если НЕ ТипЗнч(Параметры) = Тип("Массив") Тогда
		Возврат СтруктураПараметров;
	КонецЕсли;

	Для Каждого ТекПараметр Из Параметры Цикл
		СтруктураПараметров.Вставить(ТекПараметр[ИмяПоляКлюча], ТекПараметр);
	КонецЦикла;

	Возврат СтруктураПараметров;

КонецФункции // Получить()

// Процедура добавляет описание параметра в массив параметров
//   
// Параметры:
//   ИмяПараметра 			- Строка		- имя параметра объекта
//   ИмяПоляРАК 			- Строка		- имя поля, как оно возвращается утилитой администрирования кластера 1С
//   ЗначениеПоУмолчанию	- Произвольный	- значение поля объекта по умолчанию
//   ПараметрКоманды		- Строка		- строка параметра команды запуска утилиты администрирования кластера 1С
//   
Процедура ДобавитьПараметрОписанияОбъекта(Знач ИмяПараметра
									, Знач ИмяПоляРАК
									, Знач ЗначениеПоУмолчанию = ""
									, Знач ПараметрКоманды = "")

	Если НЕ ТипЗнч(Параметры) = Тип("Массив") Тогда
		Параметры = Новый Массив();
	КонецЕсли;

	ОписаниеПоля = Новый Структура();
	ОписаниеПоля.Вставить("ИмяПараметра"		, ИмяПараметра);
	ОписаниеПоля.Вставить("ИмяПоляРак"			, ИмяПоляРак);
	ОписаниеПоля.Вставить("ПараметрКоманды"		, ПараметрКоманды);
	ОписаниеПоля.Вставить("ЗначениеПоУмолчанию"	, ЗначениеПоУмолчанию);

	Если НЕ ЗначениеЗаполнено(ПараметрКоманды) Тогда
		ОписаниеПоля.ПараметрКоманды = "--" + ОписаниеПоля.ИмяПоляРАК;
	КонецЕсли;

	Параметры.Добавить(ОписаниеПоля);

КонецПроцедуры // ДобавитьПараметрОписанияОбъекта()

// Процедура заполняет массив описаний параметров кластера
//
Процедура ЗаполнитьПараметрыКластера()

	ДобавитьПараметрОписанияОбъекта("Ид"							, "cluster"							, , "-");
	ДобавитьПараметрОписанияОбъекта("ИнтервалПерезапуска"			, "lifetime-limit"					, 0);
	ДобавитьПараметрОписанияОбъекта("ДопустимыйОбъемПамяти"			, "max-memory-size"					, 0);
	ДобавитьПараметрОписанияОбъекта("ЗащищенноеСоединение"			, "security-level"					, 0);
	ДобавитьПараметрОписанияОбъекта("УровеньОтказоустойчивости"		, "session-fault-tolerance-level"	, 0);
	ДобавитьПараметрОписанияОбъекта("РежимРаспределенияНагрузки"	, "load-balancing-mode", 
									Перечисления.РежимыРаспределенияНагрузки.ПоПроизводительности);

	ДобавитьПараметрОписанияОбъекта("ИнтервалПревышенияДопустимогоОбъемаПамяти"		, "max-memory-time-limit"	, 0);
	ДобавитьПараметрОписанияОбъекта("ДопустимоеОтклонениеКоличестваОшибокСервера"	, "errors-count-threshold"	, 0);
	ДобавитьПараметрОписанияОбъекта("ПринудительноЗавершатьПроблемныеПроцессы"		, "kill-problem-processes",
									Перечисления.ДаНет.Нет);
	ДобавитьПараметрОписанияОбъекта("ВыключенныеПроцессыОстанавливатьЧерез"			, "expiration-timeout"		, 0);

КонецПроцедуры // ЗаполнитьПараметрыКластера()

// Процедура заполняет массив описаний параметров администратора (агента / кластера)
//
Процедура ЗаполнитьПараметрыАдминистратора()

	ДобавитьПараметрОписанияОбъекта("Имя"				, "name"	, "Администратор");
	ДобавитьПараметрОписанияОбъекта("Пароль"			, "pwd"		, "***");
	ДобавитьПараметрОписанияОбъекта("СпособАвторизации"	, "auth"	, Перечисления.СпособыАвторизации.Пароль);
	ДобавитьПараметрОписанияОбъекта("ПользовательОС"	, "os-user"	, "");
	ДобавитьПараметрОписанияОбъекта("Описание"			, "descr"	, "");

КонецПроцедуры // ЗаполнитьПараметрыАдминистратора()

// Процедура заполняет массив описаний параметров блокировки
//
Процедура ЗаполнитьПараметрыБлокировки()

	ДобавитьПараметрОписанияОбъекта("Соединение_Ид"		, "connection"	, , "-");
	ДобавитьПараметрОписанияОбъекта("Сеанс_Ид"			, "session"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Объект_Ид"			, "object"		, , "-");
	ДобавитьПараметрОписанияОбъекта("НачалоБлокировки"	, "locked"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Описание"			, "descr"		, , "-");
	
КонецПроцедуры // ЗаполнитьПараметрыБлокировки()

// Процедура заполняет массив описаний параметров информационной базы
//
Процедура ЗаполнитьПараметрыИнформационнойБазы()

	ДобавитьПараметрОписанияОбъекта("Ид"									, "infobase", , "-");
	ДобавитьПараметрОписанияОбъекта("ТипСУБД"								, "dbms",
									Перечисления.ТипыСУБД.MSSQLServer);
	ДобавитьПараметрОписанияОбъекта("АдресСервераСУБД"						, "db-server", "localhost");
	ДобавитьПараметрОписанияОбъекта("ИмяБазыСУБД"							, "db-name");
	ДобавитьПараметрОписанияОбъекта("ИмяПользователяБазыСУБД"				, "db-user", "sa");
	ДобавитьПараметрОписанияОбъекта("ПарольПользователяБазыСУБД"			, "db-pwd");
	ДобавитьПараметрОписанияОбъекта("НачалоБлокировкиСеансов"				, "denied-from", '00010101');
	ДобавитьПараметрОписанияОбъекта("ОкончаниеБлокировкиСеансов"			, "denied-to", '00010101');
	ДобавитьПараметрОписанияОбъекта("СообщениеБлокировкиСеансов"			, "denied-message");
	ДобавитьПараметрОписанияОбъекта("ПараметрБлокировкиСеансов"				, "denied-parameter");
	ДобавитьПараметрОписанияОбъекта("КодРазрешения"							, "permission-code");
	ДобавитьПараметрОписанияОбъекта("БлокировкаСеансовВключена"				, "sessions-deny",
									Перечисления.ВклВыкл.Выключено);
	ДобавитьПараметрОписанияОбъекта("БлокировкаРегламентныхЗаданийВключена"	, "scheduled-jobs-deny",
									Перечисления.ВклВыкл.Выключено);
	ДобавитьПараметрОписанияОбъекта("ВыдачаЛицензийСервером"				, "license-distribution",
									Перечисления.ПраваДоступа.Разрешено);
	
	ДобавитьПараметрОписанияОбъекта("ПараметрыВнешнегоУправленияСеансами",
									"external-session-manager-connection-string");
	
	ДобавитьПараметрОписанияОбъекта("ОбязательноеВнешнееУправлениеСеансами"	, "external-session-manager-required",
									Перечисления.ДаНет.Нет);
	ДобавитьПараметрОписанияОбъекта("ПрофильБезопасности"					, "security-profile-name");
	ДобавитьПараметрОписанияОбъекта("ПрофильБезопасностиБезопасногоРежима"	, "safe-mode-security-profile-name");

КонецПроцедуры // ЗаполнитьПараметрыИнформационнойБазы()

// Процедура заполняет массив описаний параметров менеджера кластера
//
Процедура ЗаполнитьПараметрыМенеджераКластера()

	ДобавитьПараметрОписанияОбъекта("Ид"			, "manager"	, , "-");
	ДобавитьПараметрОписанияОбъекта("ИдПроцессаОС"	, "pid"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Назначение"	, "using"	, , "-");
	ДобавитьПараметрОписанияОбъекта("АдресСервера"	, "host"	, , "-");
	ДобавитьПараметрОписанияОбъекта("ПортСервера"	, "port"	, , "-");
	ДобавитьПараметрОписанияОбъекта("Описание"		, "descr"	, , "-");

КонецПроцедуры // ЗаполнитьПараметрыМенеджераКластера()

// Процедура заполняет массив описаний параметров рабочего процесса
//
Процедура ЗаполнитьПараметрыРабочегоПроцесса()

    ДобавитьПараметрОписанияОбъекта("Ид"							, "process"					, , "-");
	ДобавитьПараметрОписанияОбъекта("АдресСервера"					, "host"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ПортСервера"					, "port"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ИдПроцессаОС"					, "pid"						, , "-");
	ДобавитьПараметрОписанияОбъекта("Активен"						, "is-enable"				, , "-");
	ДобавитьПараметрОписанияОбъекта("Выполняется"					, "running"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяЗапуска"					, "started-at"				, , "-");
	ДобавитьПараметрОписанияОбъекта("Использование"					, "use"						, , "-");
	ДобавитьПараметрОписанияОбъекта("ДоступнаяПроизводительность"	, "available-perfomance"	, , "-");
	ДобавитьПараметрОписанияОбъекта("Емкость"						, "capacity"				, , "-");
	ДобавитьПараметрОписанияОбъекта("КоличествоСоединений"			, "connections"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗанятьПамяти"					, "memory-size"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяПревышенияЗанятойПамяти"	, " memory-excess-time"		, , "-");
	ДобавитьПараметрОписанияОбъекта("ОбъемВыборки"					, "selection-size"			, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗатраченоКлиентом"				, "avg-back-call-time"		, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗатраченоВсего"				, "avg-call-time"			, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗатраченоСУБД"					, "avg-db-call-time"		, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗатраченоМенеджеромБлокировок"	, "avg-lock-call-time"		, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗатраченоСервером"				, "avg-server-call-time"	, , "-");
	ДобавитьПараметрОписанияОбъекта("КлиентскихПотоков"				, "avg-threads"				, , "-");

КонецПроцедуры // ЗаполнитьПараметрыРабочегоПроцесса()

// Процедура заполняет массив описаний параметров сервера
//
Процедура ЗаполнитьПараметрыСервера()
	
	ДиапазонПортов = 1561;
	КоличествоИБНаПроцесс = 8;
	КоличествоСоединенийНаПроцесс = 128;
	ПортГлавногоМенеджераКластера = 1541;

	ДобавитьПараметрОписанияОбъекта("ДиапазонПортов"					, "port-range"			, ДиапазонПортов);
	
	ДобавитьПараметрОписанияОбъекта("ЦентральныйСервер"					, "using",
									Перечисления.ВариантыИспользованияРабочегоСервера.Главный);
	ДобавитьПараметрОписанияОбъекта("МенеджерПодКаждыйСервис"			, "dedicate-managers",
										Перечисления.ВариантыРазмещенияСервисов.ВОдномМенеджере);

	ДобавитьПараметрОписанияОбъекта("КоличествоИБНаПроцесс"				, "infobases-limit"		, КоличествоИБНаПроцесс);
	ДобавитьПараметрОписанияОбъекта("МаксОбъемПамятиРабочихПроцессов"	, "memory-limit"		, 0);
	
	ДобавитьПараметрОписанияОбъекта("КоличествоСоединенийНаПроцесс"		, "connections-limit",
									КоличествоСоединенийНаПроцесс);
	ДобавитьПараметрОписанияОбъекта("ПортГлавногоМенеджераКластера"		, "cluster-port",
									ПортГлавногоМенеджераКластера);

	ДобавитьПараметрОписанияОбъекта("БезопасныйОбъемПамятиРабочихПроцессов", "safe-working-processes-memory-limit", 0);
	ДобавитьПараметрОписанияОбъекта("БезопасныйРасходПамятиЗаОдинВызов"	, "safe-call-memory-limit"	, 0);

КонецПроцедуры // ЗаполнитьПараметрыСервера()

// Процедура заполняет массив описаний параметров сервиса
//
Процедура ЗаполнитьПараметрыСервиса()

	ДобавитьПараметрОписанияОбъекта("Имя"						, "name"			,  , "-");
	ДобавитьПараметрОписанияОбъекта("ТолькоГлавныйМенеджер"		, "main-only"		,  , "-");
	ДобавитьПараметрОписанияОбъекта("Менеджер_Ид"				, "manager"			,  , "-");
	ДобавитьПараметрОписанияОбъекта("Описание"					, "descr"			,  , "-");

КонецПроцедуры // ЗаполнитьПараметрыСервиса()

// Процедура заполняет массив описаний параметров сеанса
//
Процедура ЗаполнитьПараметрыСеанса()

	ДобавитьПараметрОписанияОбъекта("Ид"							, "session"							, , "-");
	ДобавитьПараметрОписанияОбъекта("НомерСеанса"					, "session-id"						, , "-");
	ДобавитьПараметрОписанияОбъекта("ИнформационнаяБаза_Ид"			, "infobase"						, , "-");
	ДобавитьПараметрОписанияОбъекта("Соединение_Ид"					, "connection"						, , "-");
	ДобавитьПараметрОписанияОбъекта("Процесс_Ид"					, "process"							, , "-");
	ДобавитьПараметрОписанияОбъекта("Пользователь"					, "user-name"						, , "-");
	ДобавитьПараметрОписанияОбъекта("Компьютер"						, "host"							, , "-");
	ДобавитьПараметрОписанияОбъекта("Приложение"					, "app-id"							, , "-");
	ДобавитьПараметрОписанияОбъекта("Язык"							, "locale"							, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяНачала"					, "started-at"						, , "-");
	ДобавитьПараметрОписанияОбъекта("ПоследняяАктивность"			, "last-active-at"					, , "-");
	ДобавитьПараметрОписанияОбъекта("Спящий"						, "hibernate"						, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗаснутьЧерез"					, "passive-session-hibernate-time"	, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗавершитьЧерез"				, "hibernate-session-terminate-time", , "-");
	ДобавитьПараметрОписанияОбъекта("ЗаблокированоСУБД"				, "blocked-by-dbms"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗаблокированоУпр"				, "blocked-by-ls"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ДанныхВсего"					, "bytes-all"						, , "-");
	ДобавитьПараметрОписанияОбъекта("Данных5мин"					, "bytes-last-5min"					, , "-");
	ДобавитьПараметрОписанияОбъекта("КоличествоВызововВсего"		, "calls-all"						, , "-");
	ДобавитьПараметрОписанияОбъекта("КоличествоВызовов5мин"			, "calls-last-5min"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ДанныхСУБДВсего"				, "dbms-bytes-all"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ДанныхСУБД5мин"				, "dbms-bytes-last-5min"			, , "-");
	ДобавитьПараметрОписанияОбъекта("СоединениеССУБД"				, "db-proc-info"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ЗахваченоСУБД"					, "db-proc-took"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяЗахватаСУБД"				, "db-proc-took-at"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяВызововВсего"				, "duration-all"					, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяВызововСУБДВсего"			, "duration-all-dbms"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяВызововТекущее"			, "duration-current"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяВызововСУБДТекущее"		, "duration-current-dbms"			, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяВызовов5мин"				, "duration-last-5min"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ВремяВызововСУБД5мин"			, "duration-last-5min-dbms"			, , "-");
		 
КонецПроцедуры // ЗаполнитьПараметрыСеанса()

// Процедура заполняет массив описаний параметров соединения
//
Процедура ЗаполнитьПараметрыСоединения()

	ДобавитьПараметрОписанияОбъекта("Ид"					, "connection"		, , "-");
	ДобавитьПараметрОписанияОбъекта("НомерСоединения"		, "conn-id"			, , "-");
	ДобавитьПараметрОписанияОбъекта("Процесс_Ид"			, "process"			, , "-");
	ДобавитьПараметрОписанияОбъекта("ИнформационнаяБаза_Ид"	, "infobase"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Приложение"			, "application"		, , "-");
	ДобавитьПараметрОписанияОбъекта("НачалоРаботы"			, "connected-at"	, , "-");
	ДобавитьПараметрОписанияОбъекта("НомерСеанса"			, "session-number"	, , "-");
	ДобавитьПараметрОписанияОбъекта("Заблокировано"			, "blocked-by-ls"	, , "-");
		 
КонецПроцедуры // ЗаполнитьПараметрыСоединения()

// Процедура заполняет массив описаний параметров лицензии (общие)
//
Процедура ЗаполнитьПараметрыЛицензииОбщие()

	ДобавитьПараметрОписанияОбъекта("ПолноеИмя"				, "full-name"			, , "-");
	ДобавитьПараметрОписанияОбъекта("Серия"					, "series"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ВыданаСервером"		, "issued-by-server"	, , "-");
	ДобавитьПараметрОписанияОбъекта("ТипЛицензии"			, "license-type"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Сетевая"				, "net"					, , "-");
	ДобавитьПараметрОписанияОбъекта("МаксПользователей"		, "max-users-all"		, , "-");
	ДобавитьПараметрОписанияОбъекта("МаксПользователейТек"	, "max-users-cur"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Менеджер_АдресСервера"	, "rmngr-address"		, , "-");
	ДобавитьПараметрОписанияОбъекта("Менеджер_ПортСервера"	, "rmngr-port"			, , "-");
	ДобавитьПараметрОписанияОбъекта("Менеджер_ИдОС"			, "rmngr-pid"			, , "-");
	ДобавитьПараметрОписанияОбъекта("КраткоеПредставление"	, "short-presentation"	, , "-");
	ДобавитьПараметрОписанияОбъекта("ПолноеПредставление"	, "full-presentation"	, , "-");

КонецПроцедуры // ЗаполнитьПараметрыЛицензииПроцесса()

// Процедура заполняет массив описаний параметров лицензии процесса
//
Процедура ЗаполнитьПараметрыЛицензииПроцесса()

	ДобавитьПараметрОписанияОбъекта("Процесс_Ид"			, "process"				, , "-");
	ДобавитьПараметрОписанияОбъекта("Процесс_АдресСервера"	, "host"				, , "-");
	ДобавитьПараметрОписанияОбъекта("Процесс_ПортСервера"	, "port"				, , "-");
	ДобавитьПараметрОписанияОбъекта("Процесс_ИдОС"			, "pid"					, , "-");

	ЗаполнитьПараметрыЛицензииОбщие();

КонецПроцедуры // ЗаполнитьПараметрыЛицензииПроцесса()

// Процедура заполняет массив описаний параметров лицензии сеанса
//
Процедура ЗаполнитьПараметрыЛицензииСеанса()

	ДобавитьПараметрОписанияОбъекта("Сеанс_Ид"				, "session"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ИмяПользователя"		, "user-name"			, , "-");
	ДобавитьПараметрОписанияОбъекта("АдресМашины"			, "host"				, , "-");
	ДобавитьПараметрОписанияОбъекта("ТипПриложения"			, "app-id"				, , "-");

	ЗаполнитьПараметрыЛицензииОбщие();

КонецПроцедуры // ЗаполнитьПараметрыЛицензииСеанса()

// Процедура заполняет массив описаний параметров требования назначения
//
Процедура ЗаполнитьПараметрыТребованияНазначения()

	ДобавитьПараметрОписанияОбъекта("Ид"				, "rule"				, , "-");

КонецПроцедуры // ЗаполнитьПараметрыТребованияНазначения()

// Процедура заполняет массив описаний параметров профиля безопасности
//
Процедура ЗаполнитьПараметрыПрофиляБезопасности()

	ДобавитьПараметрОписанияОбъекта("Имя"				, "name"				, , "-");

КонецПроцедуры // ЗаполнитьПараметрыПрофиляБезопасности()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
