Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Элементы;
Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("summary");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	МассивИБ = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивИБ.Добавить(Новый ИнформационнаяБаза(Кластер_Агент, Кластер_Владелец, ТекОписание["infobase"]));
	КонецЦикла;

	Элементы.Заполнить(МассивИБ);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список информационных баз
//   
// Параметры:
//   Отбор					 	- Структура	- Структура отбора информационных баз (<поле>:<значение>)
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Массив - список информационных баз
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	СписокИБ = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат СписокИБ;

КонецФункции // Список()

// Функция возвращает список информационных баз
//   
// Параметры:
//   ПоляИерархии 			- Строка		- Поля для построения иерархии списка информационных баз, разделенные ","
//   ОбновитьПринудительно 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список информационных баз
//		<имя поля объекта>	- Массив(Соответствие), Соответствие	- список информационных баз или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	СписокИБ = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);
	
	Возврат СписокИБ;

КонецФункции // ИерархическийСписок()

// Функция возвращает описание информационной базы 1С
//   
// Параметры:
//   Имя		 			- Строка	- Имя информационной базы 1С
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание информационной базы 1С
//
Функция Получить(Знач Имя, Знач ОбновитьПринудительно = Ложь) Экспорт

	Отбор = Новый Структура("name", Имя);

	СписокИБ = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Если СписокИБ.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокИБ[0];

КонецФункции // Получить()

// Процедура добавляет новую информационную базу
//   
// Параметры:
//   Имя			 	- Строка		- имя информационной базы
//   Локализация	 	- Строка		- локализация базы
//   СоздатьБазуСУБД 	- Булево		- Истина - создать базу данных на сервере СУБД; Ложь - не создавать
//   ПараметрыИБ	 	- Структура		- параметры информационной базы
//
Процедура Добавить(Имя, Локализация = "ru_RU", СоздатьБазуСУБД = Ложь, ПараметрыИБ = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("create");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--name=%1", Имя));
	ПараметрыЗапуска.Добавить(СтрШаблон("--locale=%1", Локализация));
	
	Если СоздатьБазуСУБД Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--create-database", Имя));
	КонецЕсли;

	ПараметрыОбъекта = ПолучитьСтруктуруПараметровОбъекта();

	Для Каждого ТекЭлемент Из ПараметрыОбъекта Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ПараметрыИБ, ТекЭлемент.Ключ, 0);
		ПараметрыЗапуска.Добавить(СтрШаблон(ТекЭлемент.Значение.ПараметрКоманды + "=%1", ЗначениеПараметра));
	КонецЦикла;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Добавить()

// Процедура удаляет информационную базу
//   
// Параметры:
//   Имя			 	- Строка		- имя информационной базы
//   ДействияСБазойСУБД	- Строка		- "drop" - удалить базу данных; "clear" - очистить базу данных;
//										  иначе оставить базу данных как есть
//
Процедура Удалить(Имя, ДействияСБазойСУБД = "") Экспорт
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("drop");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", Получить(Имя).Ид()));
	ПараметрыЗапуска.Добавить(Получить(Имя).СтрокаАвторизации());

	Если ДействияСБазойСУБД = "drop" Тогда
		ПараметрыЗапуска.Добавить("--drop-database");
	ИначеЕсли ДействияСБазойСУБД = "clear" Тогда
		ПараметрыЗапуска.Добавить("--clear-database");
	КонецЕсли;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Удалить()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПолучитьСтруктуруПараметровОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураПараметров = Новый Соответствие();

	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ТипСУБД"								, "dbms", Перечисления.ТипыСУБД.MSSQLServer);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"АдресСервераСУБД"						, "db-server", "localhost");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ИмяБазыСУБД"							, "db-name");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ИмяПользователяБазыСУБД"				, "db-user", "sa");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПарольПользователяБазыСУБД"			, "db-pwd");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"НачалоБлокировкиСеансов"				, "denied-from", '00010101');
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ОкончаниеБлокировкиСеансов"			, "denied-to", '00010101');
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"СообщениеБлокировкиСеансов"			, "denied-message");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПараметрБлокировкиСеансов"				, "denied-parameter");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"КодРазрешения"							, "permission-code");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"БлокировкаСеансовВключена"				, "sessions-deny", Перечисления.ВклВыкл.Выключено);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"БлокировкаРегламентныхЗаданийВключена"	, "scheduled-jobs-deny", Перечисления.ВклВыкл.Выключено);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ВыдачаЛицензийСервером"				, "license-distribution", Перечисления.ПраваДоступа.Разрешено);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПараметрыВнешнегоУправленияСеансами"	, "external-session-manager-connection-string");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ОбязательноеВнешнееУправлениеСеансами"	, "external-session-manager-required", Перечисления.ДаНет.Нет);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПрофильБезопасности"					, "security-profile-name");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПрофильБезопасностиБезопасногоРежима"	, "safe-mode-security-profile-name");

	Возврат СтруктураПараметров;

КонецФункции // ПолучитьСтруктуруПараметровОбъекта()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
