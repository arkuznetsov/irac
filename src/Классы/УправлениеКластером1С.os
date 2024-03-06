// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Агент_СтрокаПодключения;   // - Строка                 - строка подключения к RAS
Перем Агент_ПроцессRAS;          // - Процесс                - процесс сервиса администрирования (RAS)
Перем Агент_ИсполнительКоманд;   // - ИсполнительКоманд      - объект - исполнитель команд
Перем Агент_Администраторы;      // - АдминистраторыАгента   - доступ к списку администраторов агента
Перем Агент_Администратор;       // - ОбъектКластера         - текущий администратор агента
Перем Кластеры_Администраторы;   // - Соответствие           - список параметров авторизации для кластеров
Перем ИБ_Администраторы;         // - Соответствие           - список параметров авторизации для информационных баз
Перем ИБ_ПараметрыСУБД;          // - Соответствие           - список параметров подключения к СУБД для информационных баз
Перем ВыводКоманды;              // - Строка                 - результат выполнения команды RAC
Перем Кластеры;                  // - Кластеры               - доступ к списку кластеров агента

Перем ПараметрыОбъекта;          // - КомандыОбъекта         - объект-генератор команд объекта кластера

Перем ОбработчикОшибок;          // - Строка                 - объект обработчик ошибок выполнения команд RAC

Перем Лог;                       // - Логирование            - объект-логгер

#Область Инициализация

// Конструктор
//
// Параметры:
//   ВерсияИлиПутьКRAC           - Строка     - маска версии 1С, путь к утилите RAC
//                                              или адрес сервиса hiRAC
//   СтрокаПодключенияСервиса    - Строка     - описание подключения к сервису администрирования (RAS)
//     Варианты:
//       Подключение к существующему сервису RAS: "<адрес сервиса RAS>:<порт сервиса RAS>"
//       Запуск локального сервиса RAS: "<адрес агента кластера 1С>:<порт агента кластера 1С>:<порт сервиса RAS>"
//     по умолчанию: "localhost:1545"
//   Администратор               - Структура    - администратор агента сервера 1С
//     *Администратор              - Строка       - имя администратора агента сервера 1С
//     *Пароль                     - Строка       - пароль администратора агента сервера 1С
//
Процедура ПриСозданииОбъекта(ВерсияИлиПутьКRAC = "8.3",
	                         СтрокаПодключенияСервиса = "localhost:1545",
	                         Администратор = Неопределено)

	Лог = Служебный.Лог();

	ПараметрыПодключения = ПараметрыПодключения(СтрокаПодключенияСервиса);

	Агент_СтрокаПодключения = СтрШаблон("%1:%2", ПараметрыПодключения.АдресRAS, ПараметрыПодключения.ПортRAS);

	Агент_ИсполнительКоманд = Новый ИсполнительКоманд(ВерсияИлиПутьКRAC);

	Если ПараметрыПодключения.ЗапуститьRAS Тогда
		ПутьКRAS = СтрЗаменить(Агент_ИсполнительКоманд.ПутьКRAC(), "rac", "ras");
		ЗапуститьСервисАдминистрирования(ПутьКRAS,
		                                 ПараметрыПодключения.ПортRAS,
		                                 ПараметрыПодключения.АдресАгента,
		                                 ПараметрыПодключения.ПортАгента);
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(ЭтотОбъект, Перечисления.РежимыАдминистрирования.Агенты);

	Если ТипЗнч(Администратор) = Тип("Структура") Тогда
		Агент_Администратор = Новый Структура("Администратор, Пароль");
		ЗаполнитьЗначенияСвойств(Агент_Администратор, Администратор);
	Иначе
		Агент_Администратор = Неопределено;
	КонецЕсли;
	
	Агент_Администраторы = Новый АдминистраторыАгента(ЭтотОбъект);
	Кластеры = Новый Кластеры(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

#КонецОбласти // Инициализация

#Область УстановкаПолучениеПараметров

// Функция возвращает строку параметров подключения к агенту администрирования (RAS)
//
// Возвращаемое значение:
//    Строка - строка параметров подключения к агенту администрирования (RAS)
//
Функция СтрокаПодключения() Экспорт

	Возврат Агент_СтрокаПодключения;

КонецФункции // СтрокаПодключения()

// Функция возвращает структуру параметров авторизации на агенте кластера 1С
//
// Возвращаемое значение:
//    Строка - структура параметров авторизации на агенте кластера 1С
//
Функция ПараметрыАвторизации() Экспорт
	
	Возврат Служебный.ПараметрыАвторизации(Перечисления.РежимыАдминистрирования.Агенты, Агент_Администратор);

КонецФункции // ПараметрыАвторизации()

// Функция возвращает строку параметров авторизации на агенте кластера 1С
//
// Возвращаемое значение:
//    Строка - строка параметров авторизации на агенте кластера 1С
//
Функция СтрокаАвторизации() Экспорт
	
	Возврат Служебный.СтрокаАвторизации(ПараметрыАвторизации());
	
КонецФункции // СтрокаАвторизации()

// Процедура устанавливает параметры авторизации на агенте кластера 1С
//
// Параметры:
//   Администратор         - Строка    - администратор агента сервера 1С
//   Пароль                - Строка    - пароль администратора агента сервера 1С
//
Процедура УстановитьАдминистратора(Администратор, Пароль) Экспорт

	Агент_Администратор = Новый Структура("Администратор, Пароль", Администратор, Пароль);

КонецПроцедуры // УстановитьАдминистратора()

// Функция возвращает строку описания подключения к серверу администрирования кластера 1С
//
// Возвращаемое значение:
//    Строка - описание подключения к серверу администрирования кластера 1С
//
Функция ОписаниеПодключения() Экспорт

	Возврат СтрШаблон("%1  (v.%2)",
	                  СокрЛП(Агент_СтрокаПодключения),
	                  СокрЛП(Агент_ИсполнительКоманд.ВерсияRAC()));

КонецФункции // ОписаниеПодключения()

// Функция возвращает адрес сервера RAS
//
// Возвращаемое значение:
//    Строка - адрес сервера RAS
//
Функция АдресRAS() Экспорт

	ОписаниеСервиса = СтрРазделить(Агент_СтрокаПодключения, ":");

	АдресСервиса = "localhost";
	Если ЗначениеЗаполнено(ОписаниеСервиса) Тогда
		АдресСервиса = ОписаниеСервиса[0];
	КонецЕсли;

	Возврат АдресСервиса;

КонецФункции // АдресRAS()

// Функция возвращает порт сервера RAS
//
// Возвращаемое значение:
//    Строка - порт сервера RAS
//
Функция ПортRAS() Экспорт

	ОписаниеСервиса = СтрРазделить(Агент_СтрокаПодключения, ":");

	ПортСервиса = "1545";
	Если ОписаниеСервиса.Количество() > 1 Тогда
		ПортСервиса = ОписаниеСервиса[1];
	КонецЕсли;

	Возврат ПортСервиса;

КонецФункции // ПортRAS()

// Функция возвращает версию утилиты администрирования RAC
//
// Возвращаемое значение:
//    Строка - версия утилиты администрирования RAC
//
Функция ВерсияRAC() Экспорт

	Возврат СокрЛП(Агент_ИсполнительКоманд.ВерсияRAC());

КонецФункции // ВерсияRAC()

// Функция возвращает лог библиотеки
//
// Возвращаемое значение:
//    Логгер - лог библиотеки
//
Функция Лог() Экспорт

	Возврат Лог;

КонецФункции // Лог()

#КонецОбласти // УстановкаПолучениеПараметров

#Область СтандартныеПараметры

// Функция возвращает описание параметров объекта
//
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает значение параметра администрирования кластера 1С
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

	ЗначениеПоля = Неопределено;

	Если НЕ Найти("АДРЕССЕРВЕРААДМИНИСТРИРОВАНИЯ, АДРЕСRAS, RAS-HOST", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = АдресRAS();
	ИначеЕсли НЕ Найти("ПОРТСЕРВЕРААДМИНИСТРИРОВАНИЯ, ПОРТARS, RAS-PORT", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ПортRAS();
	ИначеЕсли НЕ Найти("ВЕРСИЯУТИЛИТЫАДМИНИСТРИРОВАНИЯ, ВЕРСИЯRAC, RAC-VERSION", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = ВерсияRAC();
	ИначеЕсли НЕ Найти("СТРОКАПОДКЛЮЧЕНИЯ, CONNECTIONSTRING", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Агент_СтрокаПодключения;
	ИначеЕсли НЕ Найти("АДМИНИСТРАТОРЫ, ADMINISTRATORS", ВРег(ИмяПоля)) = 0 Тогда
		Агент_Администраторы.ОбновитьДанные(РежимОбновления);
		ЗначениеПоля = Агент_Администраторы;
	ИначеЕсли НЕ Найти("КЛАСТЕРЫ, CLUSTERS", ВРег(ИмяПоля)) = 0 Тогда
		Кластеры.ОбновитьДанные(РежимОбновления);
		ЗначениеПоля = Кластеры;
	Иначе
		ЗначениеПоля = Неопределено;
	КонецЕсли;
	
	Возврат ЗначениеПоля;

КонецФункции // Получить()

#КонецОбласти // СтандартныеПараметры

#Область ДочерниеОбъекты

// Функция возвращает список администраторов агента кластера 1С
//
// Возвращаемое значение:
//    Агент_Администраторы - список администраторов агента кластера 1С
//
Функция Администраторы() Экспорт

	Возврат Агент_Администраторы;

КонецФункции // Администраторы()

// Функция возвращает список кластеров 1С
//
// Возвращаемое значение:
//    Кластеры - список кластеров 1С
//
Функция Кластеры() Экспорт

	Возврат Кластеры;

КонецФункции // Кластеры()

#КонецОбласти // ДочерниеОбъекты

#Область СписокАдминистраторовКластеров

// Процедура добавляет параметры авторизации для указанного кластера
//
// Параметры:
//   Кластер_Ид         - Строка    - идентификатор кластера 1С
//   Администратор      - Строка    - администратор кластера 1С
//   Пароль             - Строка    - пароль администратора кластера 1С
//
Процедура ДобавитьАдминистратораКластера(Кластер_Ид, Администратор, Пароль) Экспорт

	Если НЕ ТипЗнч(Кластеры_Администраторы) = Тип("Соответствие") Тогда
		Кластеры_Администраторы = Новый Соответствие();
	КонецЕсли;

	Кластеры_Администраторы.Вставить(Кластер_Ид, Новый Структура("Администратор, Пароль", Администратор, Пароль));

КонецПроцедуры // ДобавитьАдминистратораКластера()

// Функция возвращает параметры авторизации для указанного кластера
//
// Параметры:
//   Кластер_Ид        - Строка    - идентификатор кластера 1С
//
// Возвращаемое значение:
//   Структура         - параметры администратора
//       Администратор      - Строка    - администратор кластера 1С
//       Пароль             - Строка    - пароль администратора кластера 1С
//
Функция ПолучитьАдминистратораКластера(Кластер_Ид) Экспорт

	Если НЕ ТипЗнч(Кластеры_Администраторы) = Тип("Соответствие") Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат Кластеры_Администраторы.Получить(Кластер_Ид); 

КонецФункции // ПолучитьАдминистратораКластера()

#КонецОбласти // СписокАдминистраторовКластеров

#Область СписокАдминистраторовИБ

// Процедура добавляет параметры авторизации для указанной информационной базы
//
// Параметры:
//   ИБ_Ид              - Строка    - идентификатор информационной базы в кластере
//   Администратор      - Строка    - администратор информационной базы
//   Пароль             - Строка    - пароль администратора информационной базы
//
Процедура ДобавитьАдминистратораИБ(ИБ_Ид, Администратор, Пароль) Экспорт

	Если НЕ ТипЗнч(ИБ_Администраторы) = Тип("Соответствие") Тогда
		ИБ_Администраторы = Новый Соответствие();
	КонецЕсли;

	ИБ_Администраторы.Вставить(ИБ_Ид, Новый Структура("Администратор, Пароль", Администратор, Пароль));

КонецПроцедуры // ДобавитьАдминистратораИБ()

// Функция возвращает параметры авторизации для указанной информационной базы
//
// Параметры:
//   ИБ_Ид              - Строка    - идентификатор информационной базы в кластере
//
// Возвращаемое значение:
//   Структура         - параметры администратора
//       Администратор      - Строка    - администратор информационной базы
//       Пароль             - Строка    - пароль администратора информационной базы
//
Функция ПолучитьАдминистратораИБ(ИБ_Ид) Экспорт

	Если НЕ ТипЗнч(ИБ_Администраторы) = Тип("Соответствие") Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат ИБ_Администраторы.Получить(ИБ_Ид); 

КонецФункции // ПолучитьАдминистратораИБ()

// Процедура добавляет параметры подключения к СУБД для указанной информационной базы
// 
// Параметры:
//   ИБ_Ид              - Строка    - идентификатор информационной базы в кластере
//   ТипСУБД            - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//   Сервер             - Строка    - адрес сервера СУБД
//   Пользователь       - Строка    - имя пользователя СУБД
//   Пароль             - Строка    - пароль пользователя СУБД
//   База               - Строка    - имя базы данных на сервере СУБД
//
Процедура ДобавитьПараметрыСУБДИБ(ИБ_Ид, ТипСУБД, Сервер, Пользователь, Пароль, База) Экспорт

	Если НЕ ТипЗнч(ИБ_ПараметрыСУБД) = Тип("Соответствие") Тогда
		ИБ_ПараметрыСУБД = Новый Соответствие();
	КонецЕсли;

	ПараметрыСУБД = Новый Структура();
	ПараметрыСУБД.Вставить("ТипСУБД"     , ТипСУБД);
	ПараметрыСУБД.Вставить("Сервер"      , Сервер);
	ПараметрыСУБД.Вставить("Пользователь", Пользователь);
	ПараметрыСУБД.Вставить("Пароль"      , Пароль);
	ПараметрыСУБД.Вставить("База"        , База);

	ИБ_ПараметрыСУБД.Вставить(ИБ_Ид, ПараметрыСУБД);

КонецПроцедуры // ДобавитьПараметрыСУБДИБ()

// Функция возвращает параметры подключения к СУБД для указанной информационной базы
//
// Параметры:
//   ИБ_Ид              - Строка    - идентификатор информационной базы в кластере
//
// Возвращаемое значение:
//   Структура         - параметры подключения к СУБД
//     * ТипСУБД            - Строка    - тип СУБД (MSSQLServer, PostgreSQL, IBMDB2, OracleDatabase)
//     * Сервер             - Строка    - адрес сервера СУБД
//     * Пользователь       - Строка    - имя пользователя СУБД
//     * Пароль             - Строка    - пароль пользователя СУБД
//     * База               - Строка    - имя базы данных на сервере СУБД
//
Функция ПараметрыСУБДИБ(ИБ_Ид) Экспорт

	Если НЕ ТипЗнч(ИБ_ПараметрыСУБД) = Тип("Соответствие") Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат ИБ_ПараметрыСУБД.Получить(ИБ_Ид); 

КонецФункции // ПараметрыСУБДИБ()

#КонецОбласти // СписокАдминистраторовИБ

#Область ИсполнительКоманд

// Функция возвращает текущий объект-исполнитель команд
//
// Возвращаемое значение:
//   ИсполнительКоманд        - текущее значение объекта-исполнителя команд
//
Функция ИсполнительКоманд() Экспорт

	Возврат Агент_ИсполнительКоманд;

КонецФункции // ИсполнительКоманд()

// Процедура устанавливает объект-исполнитель команд
//
// Параметры:
//   НовыйИсполнитель         - ИсполнительКоманд        - новый объект-исполнитель команд
//
Процедура УстановитьИсполнительКоманд(Знач НовыйИсполнитель = Неопределено) Экспорт

	Агент_ИсполнительКоманд = НовыйИсполнитель;

КонецПроцедуры // УстановитьИсполнительКоманд()

// Устанавливает объект-обработчик, который будет вызываться в случае неудачи вызова ИсполнителяКоманд.
// Объект обработчик должен определить метод ОбработатьОшибку с параметрами:
//   * ПараметрыКоманды - передадутся параметры вызванной команды
//   * АгентАдминистрирования - объект УправлениеКластером1С у которого вызывалась команда
//   * КодВозврата - на входе - полученный код возврата команды. В качестве выходного параметра 
//                   можно присвоить новое значение кода возврата
//
// Параметры:
//   НовыйОбработчикОшибок      - Произвольный      - объект-обработчик
//
Процедура УстановитьОбработчикОшибокКоманд(Знач НовыйОбработчикОшибок) Экспорт

	ОбработчикОшибок = НовыйОбработчикОшибок;

КонецПроцедуры // УстановитьОбработчикОшибокКоманд()

// Функция выполняет команду и возвращает код возврата команды
//
// Параметры:
//   ПараметрыКоманды         - Массив        - параметры выполнения команды
//
// Возвращаемое значение:
//   Число                     - Код возврата команды
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт

	СтрокаКоманды = Служебный.ПараметрыКомандыВСтроку(ПараметрыКоманды);
	СтрокаДляЛога = Служебный.ПараметрыКомандыВСтроку(ПараметрыКоманды, Истина);

	Лог.Отладка("Параметры команды: %1", СтрокаДляЛога);

	ВыводКоманды = Агент_ИсполнительКоманд.ВыполнитьКоманду(СтрокаКоманды);
	ПолученныйКод = Агент_ИсполнительКоманд.КодВозврата();

	Если НЕ ПолученныйКод = 0 И НЕ ОбработчикОшибок = Неопределено Тогда
		ОбработчикОшибок.ОбработатьОшибку(ПараметрыКоманды, ЭтотОбъект, ПолученныйКод);
	КонецЕсли;

	Возврат ПолученныйКод;

КонецФункции // ВыполнитьКоманду()

// Функция возвращает текст результата выполнения команды
//
// Параметры:
//    РазобратьВывод        - Булево      - Истина - выполнить преобразование вывода команды в структуру
//                                          Ложь - вернуть текст вывода команды как есть
//
// Возвращаемое значение:
//    Структура, Строка    - вывод команды
//
Функция ВыводКоманды(РазобратьВывод = Истина) Экспорт

	Если РазобратьВывод Тогда
		Возврат Служебный.РазобратьВыводКоманды(ВыводКоманды);
	КонецЕсли;

	Возврат ВыводКоманды;

КонецФункции // ВыводКоманды()

// Функция возвращает код возврата выполнения команды
//
// Возвращаемое значение:
//    Число - код возврата команды
//
Функция КодВозврата() Экспорт

	Возврат Агент_ИсполнительКоманд.КодВозврата();

КонецФункции // КодВозврата()

#КонецОбласти // ИсполнительКоманд

#Область ПростыеФункцииПолученияДанныхКластера

// Функция возвращает описание центрального сервера 1С в виде соответствия,
// с вложенными описаниями кластеров и всех дочерних объектов
//
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//
// Возвращаемое значение:
//    Соответствие - описание центрального сервера 1С,
//                   включая описания кластеров и всех дочерних объектов
//
Функция ОписаниеЦентральногоСервера(Знач ИмяПоляКлюча = "Имя") Экспорт

	Описание = Новый Соответствие();

	ПоляОбъекта = Новый Соответствие();

	Параметры = ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

	Для Каждого ТекПараметр Из Параметры Цикл
		ПоляОбъекта.Вставить(ТекПараметр.Значение[ИмяПоляКлюча], ЭтотОбъект.Получить(ТекПараметр.Ключ));
	КонецЦикла;

	Если ИмяПоляКлюча = "Имя" Тогда
		Описание.Вставить("СервисАдминистрирования", ПоляОбъекта);
	Иначе
		Описание.Вставить("ras", ПоляОбъекта);
	КонецЕсли;

	СписокАдминистраторов = Новый Массив();
	Попытка
		СписокАдминистраторов = ЭтотОбъект.Администраторы().Список(, , ИмяПоляКлюча);
	Исключение
		ТекстОшибки = СтрШаблон("Ошибка получения списка администраторов агента: %1",
		                        ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Лог.Информация(ТекстОшибки);
		СписокАдминистраторов.Добавить(СтрШаблон("<%1>", ТекстОшибки));
	КонецПопытки;
	
	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Агент.Администратор", ИмяПоляКлюча), СписокАдминистраторов);

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Кластер", ИмяПоляКлюча), Новый Массив());
	
	Кластеры = Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		Описание[ПолучитьИмяКоллекцииОбъектов("Кластер", ИмяПоляКлюча)].Добавить(ОписаниеКластера(ТекКластер, ИмяПоляКлюча));

	КонецЦикла;

	Возврат Описание;

КонецФункции // ОписаниеЦентральногоСервера()

// Функция возвращает описание кластера 1С в виде соответствия,
// с вложенными описаниями всех дочерних объектов
//
// Параметры:
//    КластерИлиАдрес   - Кластер, Строка   - объект или адрес кластера 1С
//    ИмяПоляКлюча      - Строка            - имя поля, значение которого будет использовано
//                                            в качестве ключа возвращаемого соответствия
//
// Возвращаемое значение:
//    Соответствие - описание кластера 1С,
//                   включая описания всех дочерних объектов
//
Функция ОписаниеКластера(Знач КластерИлиАдрес, Знач ИмяПоляКлюча = "Имя") Экспорт

	Если ТипЗнч(КластерИлиАдрес) = Тип("Строка") Тогда
		Кластер = ЭтотОбъект.Кластеры.Получить(КластерИлиАдрес);
	Иначе
		Кластер = КластерИлиАдрес;
	КонецЕсли;

	Описание = Новый Соответствие();

	Параметры = Кластер.ПараметрыОбъекта().ОписаниеСвойств(ИмяПоляКлюча);

	Для Каждого ТекПараметр Из Параметры Цикл
		Описание.Вставить(ТекПараметр.Значение[ИмяПоляКлюча], Кластер.Получить(ТекПараметр.Ключ));
	КонецЦикла;

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Кластер.Администратор", ИмяПоляКлюча),
	                  Кластер.Администраторы().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Сервер", ИмяПоляКлюча), Новый Массив());

	Серверы = Кластер.Серверы().Список();
	Для Каждого ТекСервер Из Серверы Цикл
		ПоляОбъекта = Новый Соответствие();

		Параметры = ТекСервер.ПараметрыОбъекта().ОписаниеСвойств(ИмяПоляКлюча);
	
		Для Каждого ТекПараметр Из Параметры Цикл
			ПоляОбъекта.Вставить(ТекПараметр.Значение[ИмяПоляКлюча], ТекСервер.Получить(ТекПараметр.Ключ));
		КонецЦикла;

		ПоляОбъекта.Вставить("НазначенияФункциональности",
		                     ТекСервер.НазначенияФункциональности().Список(, , ИмяПоляКлюча));
		Описание[ПолучитьИмяКоллекцииОбъектов("Сервер", ИмяПоляКлюча)].Добавить(ПоляОбъекта);
	КонецЦикла;

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("МенеджерКластера", ИмяПоляКлюча),
	                  Кластер.Менеджеры().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Сервис", ИмяПоляКлюча),
	                  Кластер.Сервисы().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("РабочийПроцесс", ИмяПоляКлюча),
	                  Кластер.РабочиеПроцессы().Список(, , ИмяПоляКлюча));
	ИмяСвойства = СтрШаблон("%1.%2",
	                        ПолучитьИмяКоллекцииОбъектов("РабочийПроцесс", ИмяПоляКлюча),
	                        ПолучитьИмяКоллекцииОбъектов("РабочийПроцесс.Лицензия", ИмяПоляКлюча));
	Описание.Вставить(ИмяСвойства, Кластер.РабочиеПроцессы().Лицензии().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("ИнформационнаяБаза", ИмяПоляКлюча),
	                  Кластер.ИнформационныеБазы().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Соединение", ИмяПоляКлюча),
	                  СоединенияКластера(Кластер, ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Сеанс", ИмяПоляКлюча), СеансыКластера(Кластер, ИмяПоляКлюча));
	ИмяСвойства = СтрШаблон("%1.%2",
	                        ПолучитьИмяКоллекцииОбъектов("Сеанс", ИмяПоляКлюча),
	                        ПолучитьИмяКоллекцииОбъектов("Сеанс.Лицензия", ИмяПоляКлюча));
	Описание.Вставить(ИмяСвойства, Кластер.Сеансы().Лицензии().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("Блокировка", ИмяПоляКлюча),
	                  Кластер.Блокировки().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности", ИмяПоляКлюча), Новый Массив());

	ПрофилиБезопасности = Кластер.ПрофилиБезопасности().Список();
	
	Для Каждого ТекПрофиль Из ПрофилиБезопасности Цикл

		ПоляОбъекта = Новый Соответствие();

		Параметры = ТекПрофиль.ПараметрыОбъекта().ОписаниеСвойств(ИмяПоляКлюча);
	
		Для Каждого ТекПараметр Из Параметры Цикл
			ПоляОбъекта.Вставить(ТекПараметр.Значение[ИмяПоляКлюча], ТекПрофиль.Получить(ТекПараметр.Ключ));
		КонецЦикла;

		ПоляОбъекта.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности.Каталог", ИмяПоляКлюча),
		                     ТекПрофиль.Каталоги().Список(, , ИмяПоляКлюча));
		ПоляОбъекта.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности.COMКласс", ИмяПоляКлюча),
		                     ТекПрофиль.COMКлассы().Список(, , ИмяПоляКлюча));
	
		ПоляОбъекта.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности.ВнешняяКомпонента", ИмяПоляКлюча),
		                     ТекПрофиль.ВнешниеКомпоненты().Список(, , ИмяПоляКлюча));
	
		ПоляОбъекта.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности.ВнешнийМодуль", ИмяПоляКлюча),
		                     ТекПрофиль.ВнешниеМодули().Список(, , ИмяПоляКлюча));
	
		ПоляОбъекта.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности.Приложение", ИмяПоляКлюча),
		                     ТекПрофиль.Приложения().Список(, , ИмяПоляКлюча));
	
		ПоляОбъекта.Вставить(ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности.ИнтернетРесурс", ИмяПоляКлюча),
		                     ТекПрофиль.ИнтернетРесурсы().Список(, , ИмяПоляКлюча));
	
		Описание[ПолучитьИмяКоллекцииОбъектов("ПрофильБезопасности", ИмяПоляКлюча)].Добавить(ПоляОбъекта);

	КонецЦикла;

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("СчетчикРесурсов", ИмяПоляКлюча),
	                  Кластер.СчетчикиРесурсов().Список(, , ИмяПоляКлюча));

	Описание.Вставить(ПолучитьИмяКоллекцииОбъектов("ОграничениеРесурсов", ИмяПоляКлюча),
	                  Кластер.ОграниченияРесурсов().Список(, , ИмяПоляКлюча));
	
	Возврат Описание;

КонецФункции // ОписаниеКластера()

// Функция возвращает список сеансов всех кластеров центрального сервера 1С в виде массива
//
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//
// Возвращаемое значение:
//   Массив Из Соответствие    - список сеансов
//
Функция ВсеСеансы(Знач ИмяПоляКлюча = "Имя") Экспорт

	ВсеКластеры = Кластеры.Список();

	ВсеСеансы = Новый Массив();

	Для Каждого ТекКластер Из ВсеКластеры Цикл
		СеансыКластера = СеансыКластера(ТекКластер, ИмяПоляКлюча);

		Для Каждого ТекСеанс Из СеансыКластера Цикл
			ВсеСеансы.Добавить(ТекСеанс);
		КонецЦикла;
	КонецЦикла;

	Возврат ВсеСеансы;

КонецФункции // ВсеСеансы()

// Функция возвращает список сеансов кластера 1С в виде массива
//
// Параметры:
//   КластерИлиАдрес  - Кластер, Строка   - объект или адрес кластера 1С
//   ИмяПоляКлюча     - Строка            - имя поля, значение которого будет использовано
//                                           в качестве ключа возвращаемого соответствия
//
// Возвращаемое значение:
//   Массив Из Соответствие    - список сеансов кластера 1С
//
Функция СеансыКластера(Знач КластерИлиАдрес = Неопределено, Знач ИмяПоляКлюча = "Имя") Экспорт

	Если НЕ ЗначениеЗаполнено(КластерИлиАдрес) Тогда
		Возврат ВсеСеансы();
	КонецЕсли;

	Если ТипЗнч(КластерИлиАдрес) = Тип("Строка") Тогда
		Кластер = ЭтотОбъект.Кластеры.Получить(КластерИлиАдрес);
	Иначе
		Кластер = КластерИлиАдрес;
	КонецЕсли;

	Возврат Кластер.Сеансы().Список(, , ИмяПоляКлюча);

КонецФункции // СеансыКластера()

// Функция возвращает список соединений всех кластеров центрального сервера 1С в виде массива
//
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//
// Возвращаемое значение:
//   Массив Из Соответствие    - список соединений
//
Функция ВсеСоединения(Знач ИмяПоляКлюча = "Имя") Экспорт

	ВсеКластеры = Кластеры.Список();

	ВсеСоединения = Новый Массив();

	Для Каждого ТекКластер Из ВсеКластеры Цикл
		СоединенияКластера = СоединенияКластера(ТекКластер, ИмяПоляКлюча);

		Для Каждого ТекСеанс Из СоединенияКластера Цикл
			ВсеСоединения.Добавить(ТекСеанс);
		КонецЦикла;
	КонецЦикла;

	Возврат ВсеСоединения;

КонецФункции // ВсеСоединения()

// Функция возвращает список соединений кластера 1С в виде массива
//
// Параметры:
//   КластерИлиАдрес   - Кластер, Строка   - объект или адрес кластера 1С
//   ИмяПоляКлюча      - Строка            - имя поля, значение которого будет использовано
//                                            в качестве ключа возвращаемого соответствия
//
// Возвращаемое значение:
//   Массив Из Соответствие    - список соединений кластера 1С
//
Функция СоединенияКластера(Знач КластерИлиАдрес = Неопределено, Знач ИмяПоляКлюча = "Имя") Экспорт

	Если НЕ ЗначениеЗаполнено(КластерИлиАдрес) Тогда
		Возврат ВсеСоединения();
	КонецЕсли;

	Если ТипЗнч(КластерИлиАдрес) = Тип("Строка") Тогда
		Кластер = ЭтотОбъект.Кластеры.Получить(КластерИлиАдрес);
	Иначе
		Кластер = КластерИлиАдрес;
	КонецЕсли;

	Возврат Кластер.Соединения().Список(, , ИмяПоляКлюча);

КонецФункции // СоединенияКластера()

#КонецОбласти // ПростыеФункцииПолученияДанныхКластера

#Область СлужебныеМетоды

// Функция возвращает имя коллекции объектов по имени типа, из указанного поля ключа
//
// Параметры:
//    ИмяТипа         - Строка     - имя типа объектов кластера
//    ИмяПоляКлюча    - Строка     - имя поля, значение которого будет возвращено
//                                   в качестве имени коллекции
//
// Возвращаемое значение:
//    Строка - имя коллекции объектов
//
Функция ПолучитьИмяКоллекцииОбъектов(Знач ИмяТипа, Знач ИмяПоляКлюча = "Имя")

	Если ИмяПоляКлюча = "Имя" Тогда
		ИмяПоляКлюча = "ИмяКоллекции";
	КонецЕсли;

	Возврат ТипыОбъектовКластера.ТипОбъекта(ИмяТипа)[ИмяПоляКлюча];

КонецФункции // ПолучитьИмяКоллекцииОбъектов()

// Функция - возвращает параметры подключения к сервису управления кластером (RAS)
//
// Параметры:
//   СтрокаПодключенияСервиса    - Строка    - описание подключения к сервису администрирования (RAS)
//     Варианты:
//       Подключение к существующему сервису RAS: "<адрес сервиса RAS>:<порт сервиса RAS>"
//       Запуск локального сервиса RAS: "<адрес агента кластера 1С>:<порт агента кластера 1С>:<порт сервиса RAS>"
//     по умолчанию: "localhost:1545"
//
// Возвращаемое значение:
//   ФиксированнаяСтруктура    - параметры подключения к сервису управления кластером (RAS)
//     *ЗапуститьRAS             - Булево    - запустить локальный агент RAS
//     *АдресRAS                 - Строка    - адрес сервиса администрирования RAS
//     *ПортRAS                  - Строка    - порт сервиса администрирования RAS
//     *АдресАгента              - Строка    - адрес агента кластера 1С
//     *ПортАгента               - Строка    - порт агента кластера 1С
//
Функция ПараметрыПодключения(СтрокаПодключенияСервиса = "localhost:1545")

	ЧастиПараметровПодключения = СтрРазделить(СтрокаПодключенияСервиса, ":");

	ПараметрыПодключения = Новый Структура();
	ПараметрыПодключения.Вставить("ЗапуститьRAS", Ложь);
	ПараметрыПодключения.Вставить("АдресRAS"    , "localhost");
	ПараметрыПодключения.Вставить("ПортRAS"     , "1545");
	ПараметрыПодключения.Вставить("АдресАгента" , "localhost");
	ПараметрыПодключения.Вставить("ПортАгента"  , "1540");

	Если ЧастиПараметровПодключения.Количество() >= 3 Тогда
		ПараметрыПодключения.ЗапуститьRAS = Истина;
		Если ЗначениеЗаполнено(ЧастиПараметровПодключения[0]) Тогда
			ПараметрыПодключения.АдресАгента = СокрЛП(ЧастиПараметровПодключения[0]);
		КонецЕсли;
		Если ЗначениеЗаполнено(ЧастиПараметровПодключения[1]) Тогда
			ПараметрыПодключения.ПортАгента = СокрЛП(ЧастиПараметровПодключения[1]);
		КонецЕсли;
		Если ЗначениеЗаполнено(ЧастиПараметровПодключения[2]) Тогда
			ПараметрыПодключения.ПортRAS = СокрЛП(ЧастиПараметровПодключения[2]);
		КонецЕсли;
	Иначе
		Если ЗначениеЗаполнено(ЧастиПараметровПодключения[0]) Тогда
			ПараметрыПодключения.АдресRAS = СокрЛП(ЧастиПараметровПодключения[0]);
		КонецЕсли;
		Если ЧастиПараметровПодключения.Количество() > 1 И ЗначениеЗаполнено(ЧастиПараметровПодключения[1]) Тогда
			ПараметрыПодключения.ПортRAS = СокрЛП(ЧастиПараметровПодключения[1]);
		КонецЕсли;
	КонецЕсли;

	Возврат Новый ФиксированнаяСтруктура(ПараметрыПодключения);

КонецФункции // ПараметрыПодключения()

// Процедура - запускает сервис администрирования кластера (RAS)
//
// Параметры:
//   ПутьКRAS        - Строка    - путь к исполняемому файлу сервиса администрирования (RAS)
//   ПортRAS         - Строка    - порт сервиса администрирования (RAS)
//   АдресАгента     - Строка    - адрес агента кластера 1С
//   ПортАгента      - Строка    - порт агента кластера 1С
//
Процедура ЗапуститьСервисАдминистрирования(ПутьКRAS,
                                           ПортRAS = "1545",
                                           АдресАгента = "localhost",
                                           ПортАгента = "1540") Экспорт

	СтрокаЗапускаRAS = СтрШаблон("""%1"" cluster --port=%2 %3:%4", ПутьКRAS, ПортRAS, АдресАгента, ПортАгента);

	Агент_ПроцессRAS = СоздатьПроцесс(СтрокаЗапускаRAS);
	Агент_ПроцессRAS.Запустить();

КонецПроцедуры // ЗапуститьСервисАдминистрирования()

// Процедура - завершает процесс сервиса администрирования кластера (RAS)
//
Процедура ЗавершитьСервисАдминистрирования() Экспорт

	Если Агент_ПроцессRAS = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Агент_ПроцессRAS.Завершить();

КонецПроцедуры // ЗавершитьСервисАдминистрирования()

#КонецОбласти // СлужебныеМетоды