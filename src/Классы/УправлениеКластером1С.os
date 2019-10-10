// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Агент_СтрокаПодключения;
Перем Агент_ИсполнительКоманд;
Перем Агент_Администраторы;
Перем Агент_Администратор;
Перем Кластеры_Администраторы;
Перем ВыводКоманды;
Перем Кластеры;

Перем ПараметрыОбъекта;

Перем ОбработчикОшибок;

Перем Лог;

#Область Инициализация

// Конструктор
//   
// Параметры:
//   ВерсияИлиПутьКУтилитеАдминистрирования - Строка     - маска версии 1С, путь к утилите RAC
//                                                         или адрес сервиса hiRAC
//   СтрокаПодключенияСервиса               - Строка     - адрес сервиса агента администрирования
//                                                         (по умолчанию: "localhost:1545")
//   Администратор                          - Структура  - администратор агента сервера 1С
//       Администратор                         - Строка     - имя администратора агента сервера 1С
//       Пароль                                - Строка     - пароль администратора агента сервера 1С
//
Процедура ПриСозданииОбъекта(ВерсияИлиПутьКУтилитеАдминистрирования = "8.3"
	                       , СтрокаПодключенияСервиса = "localhost:1545"
	                       , Администратор = Неопределено)

	Лог = Служебный.Лог();

	ОписаниеСервиса = СтрРазделить(СтрокаПодключенияСервиса, ":");

	АдресСервиса = "localhost";
	ПортСервиса = "1545";
	Если ОписаниеСервиса.Количество() > 0 Тогда
		АдресСервиса = ОписаниеСервиса[0];
	КонецЕсли;
	Если ОписаниеСервиса.Количество() > 1 Тогда
		ПортСервиса = ОписаниеСервиса[1];
	КонецЕсли;

	Агент_СтрокаПодключения = СтрШаблон("%1:%2", АдресСервиса, ПортСервиса);

	Агент_ИсполнительКоманд = Новый ИсполнительКоманд(ВерсияИлиПутьКУтилитеАдминистрирования);

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Агент);

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

// Функция возвращает строку параметров авторизации на агенте кластера 1С
//   
// Возвращаемое значение:
//    Строка - строка параметров авторизации на агенте кластера 1С
//
Функция СтрокаАвторизации() Экспорт
	
	Если НЕ ТипЗнч(Агент_Администратор)  = Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;

	Если НЕ Агент_Администратор.Свойство("Администратор") Тогда
		Возврат "";
	КонецЕсли;

	Если ПустаяСтрока(Агент_Администратор.Администратор) Тогда
		Возврат "";
	КонецЕсли;

	СтрокаАвторизации = СтрШаблон("--agent-user=%1", Служебный.ОбернутьВКавычки(Агент_Администратор.Администратор));

	Если НЕ ПустаяСтрока(Агент_Администратор.Пароль) Тогда
		СтрокаАвторизации = СтрокаАвторизации + СтрШаблон(" --agent-pwd=%1", Агент_Администратор.Пароль);
	КонецЕсли;
	        
	Возврат СтрокаАвторизации;
	
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
					  СокрЛП(Агент_ИсполнительКоманд.ВерсияУтилитыАдминистрирования()));

КонецФункции // ОписаниеПодключения()

// Функция возвращает адрес сервера RAS
//   
// Возвращаемое значение:
//    Строка - адрес сервера RAS
//
Функция АдресСервераАдминистрирования() Экспорт

	ОписаниеСервиса = СтрРазделить(Агент_СтрокаПодключения, ":");

	АдресСервиса = "localhost";
	Если ОписаниеСервиса.Количество() > 0 Тогда
		АдресСервиса = ОписаниеСервиса[0];
	КонецЕсли;

	Возврат АдресСервиса;

КонецФункции // АдресСервераАдминистрирования()

// Функция возвращает порт сервера RAS
//   
// Возвращаемое значение:
//    Строка - порт сервера RAS
//
Функция ПортСервераАдминистрирования() Экспорт

	ОписаниеСервиса = СтрРазделить(Агент_СтрокаПодключения, ":");

	ПортСервиса = "1545";
	Если ОписаниеСервиса.Количество() > 1 Тогда
		ПортСервиса = ОписаниеСервиса[1];
	КонецЕсли;

	Возврат ПортСервиса;

КонецФункции // ПортСервераАдминистрирования()

// Функция возвращает версию утилиты администрирования RAC
//   
// Возвращаемое значение:
//    Строка - версия утилиты администрирования RAC
//
Функция ВерсияУтилитыАдминистрирования() Экспорт

	Возврат СокрЛП(Агент_ИсполнительКоманд.ВерсияУтилитыАдминистрирования());

КонецФункции // ВерсияУтилитыАдминистрирования()

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

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает значение параметра администрирования кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно   - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Найти(ВРЕг("АдресСервераАдминистрирования, ras-host"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат АдресСервераАдминистрирования();
	ИначеЕсли НЕ Найти(ВРЕг("ПортСервераАдминистрирования, ras-port"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ПортСервераАдминистрирования();
	ИначеЕсли НЕ Найти(ВРЕг("ВерсияУтилитыАдминистрирования, rac-version"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ВерсияУтилитыАдминистрирования();
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
//   * АгентАдминистрирования - объект АдминистрированиеКластера у которого вызывалась команда
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
Функция ВыполнитьКоманду(ПараметрыКоманды) Экспорт

	ВыводКоманды = Агент_ИсполнительКоманд.ВыполнитьКоманду(ПараметрыКоманды);
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
// Возвращаемое значение:
//    Соответствие - описание центрального сервера 1С,
//                   включая описания кластеров и всех дочерних объектов
//
Функция ОписаниеЦентральногоСервера() Экспорт

	Описание = Новый Соответствие();

	Описание.Вставить("СервисАдминистрирования",
	                  ПолучитьПоляОбъекта(ЭтотОбъект));

	Описание.Вставить("Администраторы",
	                  ПолучитьСписокОбъектов(ЭтотОбъект.Администраторы().Список(),
	                  ЭтотОбъект.Администраторы().ПараметрыОбъекта()));

	Описание.Вставить("Кластеры", Новый Массив());
	
	Кластеры = Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		Описание["Кластеры"].Добавить(ОписаниеКластера(ТекКластер));

	КонецЦикла;

	Возврат Описание;

КонецФункции // ОписаниеЦентральногоСервера()

// Функция возвращает описание кластера 1С в виде соответствия,
// с вложенными описаниями всех дочерних объектов
//   
// Параметры:
//    КластерИлиАдрес  - Кластер, Строка   - объект или адрес кластера 1С
//
// Возвращаемое значение:
//    Соответствие - описание кластера 1С,
//                   включая описания всех дочерних объектов
//
Функция ОписаниеКластера(Знач КластерИлиАдрес) Экспорт

	Если ТипЗнч(КластерИлиАдрес) = Тип("Строка") Тогда
		Кластер = ЭтотОбъект.Кластеры.Получить(КластерИлиАдрес);
	Иначе
		Кластер = КластерИлиАдрес;
	КонецЕсли;

	Описание = ПолучитьПоляОбъекта(Кластер);

	Описание.Вставить("Администраторы",
	                  ПолучитьСписокОбъектов(Кластер.Администраторы().Список(),
	                  Кластер.Администраторы().ПараметрыОбъекта()));

	Описание.Вставить("Серверы", Новый Массив());

	Серверы = Кластер.Серверы().Список();
	Для Каждого ТекСервер Из Серверы Цикл
		ПоляОбъекта = ПолучитьПоляОбъекта(ТекСервер);
		ПоляОбъекта.Вставить("НазначенияФункциональности",
		                     ПолучитьСписокОбъектов(ТекСервер.НазначенияФункциональности().Список()));
		Описание["Серверы"].Добавить(ПоляОбъекта);
	КонецЦикла;

	Описание.Вставить("Менеджеры",
	                  ПолучитьСписокОбъектов(Кластер.Менеджеры().Список()));

	Описание.Вставить("Сервисы",
	                  ПолучитьСписокОбъектов(Кластер.Сервисы().Список()));

	Описание.Вставить("РабочиеПроцессы",
	                  ПолучитьСписокОбъектов(Кластер.РабочиеПроцессы().Список()));
	Описание.Вставить("РабочиеПроцессы.Лицензии",
	                  ПолучитьСписокОбъектов(Кластер.РабочиеПроцессы().Лицензии().Список(),
	                                         Кластер.РабочиеПроцессы().ПараметрыЛицензий()));

	Описание.Вставить("ИнформационныеБазы",
	                  ПолучитьСписокОбъектов(Кластер.ИнформационныеБазы().Список()));
	Описание.Вставить("Соединения",
	                  ПолучитьСписокОбъектов(Кластер.Соединения().Список()));

	Описание.Вставить("Сеансы",
	                  ПолучитьСписокОбъектов(Кластер.Сеансы().Список()));
	Описание.Вставить("Сеансы.Лицензии",
	                  ПолучитьСписокОбъектов(Кластер.Сеансы().Лицензии().Список(),
	                                         Кластер.Сеансы().ПараметрыЛицензий()));

	Описание.Вставить("Блокировки",
	                  ПолучитьСписокОбъектов(Кластер.Блокировки().Список()));

	Описание.Вставить("ПрофилиБезопасности", Новый Массив());

	ПрофилиБезопасности = Кластер.ПрофилиБезопасности().Список();
	
	Для Каждого ТекПрофиль Из ПрофилиБезопасности Цикл

		ПоляОбъекта = ПолучитьПоляОбъекта(ТекПрофиль);

		ПоляОбъекта.Вставить("Каталоги",
		                     ПолучитьСписокОбъектов(ТекПрофиль.Каталоги().Список()));
		ПоляОбъекта.Вставить("COMКлассы",
		                     ПолучитьСписокОбъектов(ТекПрофиль.COMКлассы().Список()));
	
		ПоляОбъекта.Вставить("ВнешниеКомпоненты",
		                     ПолучитьСписокОбъектов(ТекПрофиль.ВнешниеКомпоненты().Список()));
	
		ПоляОбъекта.Вставить("ВнешниеМодули",
		                     ПолучитьСписокОбъектов(ТекПрофиль.ВнешниеМодули().Список()));
	
		ПоляОбъекта.Вставить("Приложения",
		                     ПолучитьСписокОбъектов(ТекПрофиль.Приложения().Список()));
	
		ПоляОбъекта.Вставить("ИнтернетРесурсы",
		                     ПолучитьСписокОбъектов(ТекПрофиль.ИнтернетРесурсы().Список()));
	
		Описание["ПрофилиБезопасности"].Добавить(ПоляОбъекта);

	КонецЦикла;

	Описание.Вставить("СчетчикиРесурсов",
	                  ПолучитьСписокОбъектов(Кластер.СчетчикиРесурсов().Список()));

	Описание.Вставить("ОграниченияРесурсов",
	                  ПолучитьСписокОбъектов(Кластер.ОграниченияРесурсов().Список()));
	
	Возврат Описание;

КонецФункции // ОписаниеКластера()

#КонецОбласти // ПростыеФункцииПолученияДанныхКластера

#Область СлужебныеМетоды

Функция ПолучитьСписокОбъектов(Знач Список, Знач Параметры = Неопределено)

	СписокОбъектов = Новый Массив();

	Для Каждого ТекОбъект Из Список Цикл
		СписокОбъектов.Добавить(ПолучитьПоляОбъекта(ТекОбъект, Параметры));
	КонецЦикла;

	Возврат СписокОбъектов;

КонецФункции // ПолучитьСписокОбъектов()

Функция ПолучитьПоляОбъекта(Знач ОбъектКластера, Знач Параметры = Неопределено)

	ПоляОбъекта = Новый Соответствие();

	ИспользоватьПараметрыОбъекта = (Параметры = Неопределено);
	Если ИспользоватьПараметрыОбъекта Тогда
		Параметры = ОбъектКластера.ПараметрыОбъекта();
	КонецЕсли;

	Для Каждого ТекПараметр Из Параметры Цикл
		Если ИспользоватьПараметрыОбъекта Тогда
			Ключ = ТекПараметр.Ключ;
		Иначе
			Ключ = ТекПараметр.Значение.ИмяРАК;
		КонецЕсли;
		ПоляОбъекта.Вставить(ТекПараметр.Значение.ИмяРАК, ОбъектКластера.Получить(Ключ));
	КонецЦикла;

	Возврат ПоляОбъекта;

КонецФункции // ПолучитьПоляОбъекта()

#КонецОбласти // СлужебныеМетоды