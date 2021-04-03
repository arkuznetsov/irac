// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

// Класс хранящий структуру свойств и команд объекта указанного типа

Перем Кластер_Агент;               // УправлениеКластером1С - объект управления кластером 1С
Перем ТипОбъекта;                  // структура описания типа объектов (Кластер, Сервер, ИБ и т.п.)
Перем ОписаниеСвойств;             // структура описания свойств объекта
Перем ОписаниеКоманд;              // структура описания команд объекта
Перем ПараметрыЗапуска;            // массив параметров запуска команды утилиты RAC
Перем КэшПараметровАвторизации;    // соответствие, содержащее параметры авторизации
Перем ЗначенияПараметров;          // значения именованых параметров объекта

Перем Лог;

#Область Инициализация

// Конструктор
//   
// Параметры:
//   АгентКластера             - АгентКластера  - ссылка на объект управления кластером 1С
//   ИмяТипаОбъекта            - Строка         - имя типа объекта для которого создается структура параметров
//   ЗначенияПараметровКоманд  - Структура      - список параметров команд:
//                                                    Ключ - имя параметра
//                                                    Значение - значение параметра
//
Процедура ПриСозданииОбъекта(АгентКластера, ИмяТипаОбъекта, ЗначенияПараметровКоманд = Неопределено)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;

	ТипОбъекта = ТипыОбъектовКластера.ТипОбъекта(ИмяТипаОбъекта);

	ОписаниеСвойств = ТипыОбъектовКластера.СвойстваОбъекта(ИмяТипаОбъекта);

	ОписаниеКоманд = ТипыОбъектовКластера.КомандыОбъекта(ИмяТипаОбъекта);

	УстановитьЗначенияПараметровКоманд(ЗначенияПараметровКоманд);

КонецПроцедуры // ПриСозданииОбъекта()

#КонецОбласти // Инициализация

#Область ПрограммныйИнтерфейс

// Процедура устанавливает значения параметров команд
//   
// Параметры:
//   ЗначенияПараметровКоманд       - Соответствие      - список параметров команд:
//       *<имя параметра>               - Произвольный      - значение параметра команды
//   Очистить                       - Булево            - Истина - очистить значения параметров перед заполнением
//                                                        Ложь - добавить параметры к существующим
//                                                              (одноименные будут перезаполнены)
//
Процедура УстановитьЗначенияПараметровКоманд(Знач ЗначенияПараметровКоманд, Знач Очистить = Ложь) Экспорт

	Если НЕ ТипЗнч(ЗначенияПараметров) = Тип("Соответствие") ИЛИ Очистить Тогда
		ЗначенияПараметров = Новый Соответствие();
	КонецЕсли;

	Если ТипЗнч(ЗначенияПараметровКоманд) = Тип("Соответствие") Тогда
		Для Каждого ТекЭлемент Из ЗначенияПараметровКоманд Цикл
			ЗначенияПараметров.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры // УстановитьЗначенияПараметровКоманд()

// Функция возвращает коллекцию описаний свойств объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция описаний свойств объекта, для получения/изменения значений
//
Функция ОписаниеСвойств(Знач ИмяПоляКлюча = "Имя") Экспорт
	
	СтруктураОписаний = Новый Соответствие();

	Если НЕ ТипЗнч(ОписаниеСвойств) = Тип("Массив") Тогда
		Возврат СтруктураОписаний;
	КонецЕсли;

	Для й = 0 По ОписаниеСвойств.ВГраница() Цикл
		СтруктураОписаний.Вставить(ОписаниеСвойств[й][ИмяПоляКлюча], ОписаниеСвойств[й]);
	КонецЦикла;

	Возврат СтруктураОписаний;

КонецФункции // ОписаниеСвойств()

// Функция выполняет заполнение массива параметров запуска команды
// и возвращает результирующий массив
//   
// Параметры:
//   ИмяКоманды         - Строка    - имя команды для которой выпоняется заполнение
//   
// Возвращаемое значение:
//    Массив - параметры запуска команды
//
Функция ПараметрыКоманды(Знач ИмяКоманды) Экспорт
	
	ПараметрыЗапуска = Новый Массив();
	КэшПараметровАвторизации = Новый Соответствие();

	Команда = ОписаниеКоманд[ИмяКоманды];

	ДобавитьПараметрПоИмени("СтрокаПодключенияАгента");

	Если ТипОбъекта.Свойство("Владелец") Тогда
		ДобавитьПараметрСтроку(ТипОбъекта.Владелец.РежимАдминистрирования);
	Иначе
		ДобавитьПараметрСтроку(ТипОбъекта.РежимАдминистрирования);
	КонецЕсли;

	АвторизацияАгента = Ложь;
	Если Команда.Свойство("АвторизацияАгента") Тогда
		АвторизацияАгента = Команда.АвторизацияАгента;
	КонецЕсли;
	
	Если АвторизацияАгента Тогда
		ДобавитьПараметрыАвторизации(Перечисления.РежимыАдминистрирования.Агенты,
		                             "ПараметрыАвторизацииАгента",
									 "agent");
	КонецЕсли;

	Если Команда.Кластер Тогда
	 	ДобавитьИменованныйПараметр("cluster", "ИдентификаторКластера", Истина);
		ДобавитьПараметрыАвторизации(Перечисления.РежимыАдминистрирования.Кластеры,
									 "ПараметрыАвторизацииКластера",
									 ЗначенияПараметров["ИдентификаторКластера"]);
	КонецЕсли;
	
	Если ТипОбъекта.Свойство("Владелец") И Команда.ДочернийРежимАдминистрирования Тогда
		ДобавитьПараметрСтроку(ТипОбъекта.РежимАдминистрирования);
	КонецЕсли;

	Для Каждого ТекПараметр Из Команда.ОбщиеПараметры Цикл
		ДобавитьПараметрКоманды(ТекПараметр);
	КонецЦикла;

	ДобавитьПараметрСтроку(Команда.ИмяРАК);

	Для Каждого ТекПараметр Из Команда.ПараметрыКоманды Цикл
		ДобавитьПараметрКоманды(ТекПараметр);
	КонецЦикла;

	Если Команда.Свойство("ЗначенияПолей") И ЗначениеЗаполнено(Команда.ЗначенияПолей) Тогда
		ДобавитьПрочиеПараметрыКоманды(Команда.ЗначенияПолей);
	КонецЕсли;

	Для Каждого ТекЭлемент Из КэшПараметровАвторизации Цикл
		Для й = 0 По ПараметрыЗапуска.ВГраница() Цикл
			Если НЕ (ТипЗнч(ПараметрыЗапуска[й]) = Тип("Структура")
			   И ПараметрыЗапуска[й].Свойство("Значение")) Тогда
				Продолжить;
			КонецЕсли;
			ПараметрыЗапуска[й].Значение = СтрЗаменить(ПараметрыЗапуска[й].Значение,
			                                           ТекЭлемент.Ключ,
			                                           Служебный.ОбернутьВКавычки(ТекЭлемент.Значение));
		КонецЦикла;
	КонецЦикла;

	Возврат ПараметрыЗапуска;

КонецФункции // ПараметрыКоманды()

// Функция возвращает строку параметров запуска команды с заменой значений "приватных" параметров
// на символы подстановки и соответствие параметров подстановки и значений
// 
// Параметры:
//   ИмяКоманды      - Строка         - имя команды для которой выпоняется заполнение
//   Подстановки     - Соответствие   - (Возвр.) соответствие символов подстановки и значений
// 
// Возвращаемое значение:
//    Строка - строка параметров запуска команды
//
Функция ПараметрыКомандыСтрокойСПодстановками(ИмяКоманды, Подстановки = Неопределено) Экспорт

	ПараметрыКоманды = ПараметрыКоманды(ИмяКоманды);

	Возврат Служебный.ПараметрыКомандыВСтрокуСПодстановками(ПараметрыКоманды, Подстановки);

КонецФункции // ПараметрыКомандыСтрокойСПодстановками()

// Функция возвращает строку параметров запуска команды
// 
// Параметры:
//   ИмяКоманды      - Строка         - имя команды для которой выпоняется заполнение
//   ДляЛога         - Булево         - Истина - приватные значения параметров (пользватель / пароль и т.п.)
//                                      будут скрыты символами "******"
// 
// Возвращаемое значение:
//    Строка - строка параметров запуска команды
//
Функция ПараметрыКомандыСтрокой(ИмяКоманды, ДляЛога = Ложь) Экспорт

	ПараметрыКоманды = ПараметрыКоманды(ИмяКоманды);

	Возврат Служебный.ПараметрыКомандыВСтроку(ПараметрыКоманды, ДляЛога);

КонецФункции // ПараметрыКомандыСтрокой()

Функция ВыполнитьКоманду(Знач ИмяКоманды) Экспорт

	Возврат Кластер_Агент.ВыполнитьКоманду(ПараметрыКоманды(ИмяКоманды));

КонецФункции // ВыполнитьКоманду()

// Функция возвращает описание текущего типа объекта
// 
// Возвращаемое значение:
//   Структура                                 - описание типа объектов
//       *Имя                      - Строка        - имя типа объектов
//       *РежимАдминистрирования   - Строка        - режим утилиты RAC (agent, cluster, infobase и т.п.)
//       *Владелец                 - Структура     - описание типа объекта, владельца 
//                                                   (например: для типа "Кластер.Администратор"
//                                                   будет содержать описание типа "Кластер")
// 
Функция ТипОбъекта() Экспорт

	Возврат ТипОбъекта;

КонецФункции // ТипОбъекта()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедуры

// Процедура добавляет параметр указанный параметр команды
//   
// Параметры:
//   Параметр       - Строка, Структура   - строковый параметр или структура с описанием параметра
//       *Флаг          - Строка              - имя параметра-флага разрешающего добавление параметра
//       *Шаблон        - Строка              - строка шаблона добавления параметра (например: "--cluster=%1")
//       *Параметр      - Строка              - имя добавляемого параметра или подстановки в шаблон
//       *Обязательный  - Булево              - Истина - при заполнении будет проверено наличие параметра
//   
Процедура ДобавитьПараметрКоманды(Знач Параметр)

	Если ТипЗнч(Параметр) = Тип("Структура") Тогда

		Обязательный = Ложь;
		Если Параметр.Свойство("Обязательный") Тогда
			Обязательный = Параметр.Обязательный;
		КонецЕсли;

		Если Параметр.Свойство("Авторизация") Тогда
			ДобавитьПараметрыАвторизации(Параметр.Авторизация, Параметр.Параметр, ЗначенияПараметров[Параметр.ПараметрИд]);
		ИначеЕсли Параметр.Свойство("ПараметрРАК") Тогда
			ДобавитьИменованныйПараметр(Параметр.ПараметрРАК, Параметр.Параметр, Обязательный);
		ИначеЕсли Параметр.Свойство("Флаг") Тогда
			ДобавитьПараметрФлаг(Параметр.Флаг, Параметр.Параметр);
		Иначе
			ДобавитьПараметрПоИмени(Параметр.Параметр);
		КонецЕсли;

	Иначе
		ДобавитьПараметрСтроку(Параметр);
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрКоманды()

// Процедура добавляет параметры команды из описания свойств объекта
// проверяя флаг использования свойства для различных операций
//   
// Параметры:
//   ИмяФлагаРазрешения       - Строка          - имя проверяемого флага разрешения
//                                                (Чтение, Добавление, Изменение и т.п.)
//   ВключаяПараметры         - Строка          - список добавляемых параметров, разделенных ","
//   ИсключаяПараметры        - Строка          - список исключаемых параметров, разделенных ","
//   
Процедура ДобавитьПрочиеПараметрыКоманды(Знач ИмяФлагаРазрешения
	                                   , Знач ВключаяПараметры = ""
	                                   , Знач ИсключаяПараметры = "")

	ВключаяПараметры = СтрРазделить(ВключаяПараметры, ",", Ложь);
	Для й = 0 По ВключаяПараметры.ВГраница() Цикл
		ВключаяПараметры[й] = СокрЛП(ВключаяПараметры[й]);
	КонецЦикла;

	ИсключаяПараметры = СтрРазделить(ИсключаяПараметры, ",", Ложь);
	Для й = 0 По ИсключаяПараметры.ВГраница() Цикл
		ИсключаяПараметры[й] = СокрЛП(ИсключаяПараметры[й]);
	КонецЦикла;

	ВсеПараметры = ОписаниеСвойств();

	Для Каждого ТекЭлемент Из ВсеПараметры Цикл
		
		Если ЗначениеЗаполнено(ВключаяПараметры)
		   И ВключаяПараметры.Найти(ТекЭлемент.Ключ) = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Если ЗначениеЗаполнено(ИсключаяПараметры)
		   И НЕ ИсключаяПараметры.Найти(ТекЭлемент.Ключ) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
	
		Если ЗначениеЗаполнено(ИмяФлагаРазрешения) И НЕ ТекЭлемент.Значение[ИмяФлагаРазрешения] Тогда
			Продолжить;
		КонецЕсли;

		Если ВРег(ИмяФлагаРазрешения) = "ИЗМЕНЕНИЕ" И ЗначенияПараметров[ТекЭлемент.Ключ] = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Если ЗначенияПараметров.Получить(ТекЭлемент.Ключ) = Неопределено
		   И ЗначениеЗаполнено(ТекЭлемент.Значение.ПоУмолчанию) Тогда
			ЗначенияПараметров.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение.ПоУмолчанию);
		КонецЕсли;

		ДобавитьИменованныйПараметр(ТекЭлемент.Значение.ИмяРАК, ТекЭлемент.Ключ);
		
	КонецЦикла;

КонецПроцедуры // ДобавитьПрочиеПараметрыКоманды()

// Процедура добавляет параметр-флаг в массив параметров запуска команды
//   
// Параметры:
//   Флаг               - Строка            - представление параметра-флага
//   Параметр           - Строка            - имя параметра в структуре значений параметров,
//                                            для проверки установки флага
//   
Процедура ДобавитьПараметрФлаг(Знач Флаг, Знач Параметр)

	УстановитьФлаг = ЗначенияПараметров.Получить(Параметр);
	Если НЕ ТипЗнч(УстановитьФлаг) = Тип("Булево") Тогда
		УстановитьФлаг = Ложь;
	КонецЕсли;

	Если УстановитьФлаг Тогда
		ПараметрыЗапуска.Добавить(Новый Структура("Параметр, Флаг", Флаг, Истина));
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрФлаг()

// Процедура добавляет переданное значение в массив параметров запуска команды
//   
// Параметры:
//   Параметр               - Строка            - добавляемое значение
//   Обязательный           - Булево            - Истина - если параметр не заполнен будет выдано исключение
//   ДобавлятьПустой        - Булево            - Истина - если параметр не заполнен будет добавлена пустая строка
//   
Процедура ДобавитьПараметрСтроку(Знач Параметр, Обязательный = Ложь, ДобавлятьПустой = Истина)

	Если НЕ ТипЗнч(Параметр) = Тип("Строка") Тогда
		Параметр = "";
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Параметр) И Обязательный Тогда
		ВызватьИсключение "Не заполнен обязательный параметр!";
	КонецЕсли;

	Если ЗначениеЗаполнено(Параметр) ИЛИ ДобавлятьПустой Тогда
		ПараметрыЗапуска.Добавить(Параметр);
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрСтроку()

// Процедура добавляет значение параметра из структуры значений параметров в массив параметров запуска команды
//   
// Параметры:
//   Имя                    - Строка            - имя параметра в структуре значений параметров
//   Обязательный           - Булево            - Истина - если значение параметра не найдено
//                                                         или не заполнено будет выдано исключение
//   ДобавлятьПустой        - Булево            - Истина - если значение параметра не найдено
//                                                         или не заполнено будет добавлена пустая строка
//   
Процедура ДобавитьПараметрПоИмени(Знач Имя, Обязательный = Ложь, ДобавлятьПустой = Истина)

	Параметр = ЗначенияПараметров.Получить(Имя);
	Если Параметр = Неопределено Тогда
		Параметр = "";
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Параметр) И Обязательный Тогда
		ВызватьИсключение СтрШаблон("Не заполнен обязательный параметр %1!", Имя);
	КонецЕсли;

	Если ЗначениеЗаполнено(Параметр) ИЛИ ДобавлятьПустой Тогда
		ПараметрыЗапуска.Добавить(Параметр);
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрПоИмени()

// Процедура добавляет значение параметра из структуры значений параметров в массив параметров запуска команды
//   
// Параметры:
//   ТипОбъектаАвторизации  - Строка            - тип объекта авторизации (agent, cluster, infobase)
//   Имя                    - Строка            - имя параметра в структуре значений параметров
//   Ид                     - Строка            - идентификатор параметров авторизации
//   Обязательный           - Булево            - Истина - если значение параметра не найдено
//                                                         или не заполнено будет выдано исключение
//
Процедура ДобавитьПараметрыАвторизации(Знач ТипОбъектаАвторизации, Знач Имя, Знач Ид, Знач Обязательный = Ложь)

	Параметр = ЗначенияПараметров.Получить(Имя);
	Если Параметр = Неопределено И Обязательный Тогда
		ВызватьИсключение СтрШаблон("Не заполнен обязательный параметр %1!", Имя);
	КонецЕсли;

	ПараметрыАвторизации = Служебный.ПараметрыАвторизации(ТипОбъектаАвторизации, Параметр);

	Если НЕ ПараметрыАвторизации.Свойство("Администратор") Тогда
		Возврат;
	КонецЕсли;

	Если ПустаяСтрока(ПараметрыАвторизации.Администратор) Тогда
		Возврат;
	КонецЕсли;

	КэшПараметровАвторизации.Вставить(СтрШаблон("%1_user", Ид), ПараметрыАвторизации.Администратор);

	ПараметрыЗапуска.Добавить(Новый Структура("Параметр, Значение, Приватный",
	                                          СтрШаблон("%1-user", ПараметрыАвторизации.Тип),
	                                          СтрШаблон("%1_user", Ид),
	                                          Истина));

	Если НЕ ПустаяСтрока(ПараметрыАвторизации.Пароль) Тогда
	    КэшПараметровАвторизации.Вставить(СтрШаблон("%1_pwd", Ид), ПараметрыАвторизации.Пароль);

		ПараметрыЗапуска.Добавить(Новый Структура("Параметр, Значение, Приватный",
		                                          СтрШаблон("%1-pwd", ПараметрыАвторизации.Тип),
		                                          СтрШаблон("%1_pwd", Ид),
		                                          Истина));
	КонецЕсли;
	
КонецПроцедуры // ДобавитьПараметрыАвторизации()

// Процедура выполняет подстановку значения параметра из структуры значений параметров в шаблон
// и добавляет результат в массив параметров запуска команды
//   
// Параметры:
//   ПараметрРАК            - Строка            - имя добавляемого параметра командной строки RAC
//   ИмяЗначения            - Строка            - имя значения параметра в структуре значений параметров
//   Обязательный           - Булево            - Истина - если значение параметра не найдено
//                                                         или не заполнено будет выдано исключение
//   
Процедура ДобавитьИменованныйПараметр(Знач ПараметрРАК, Знач ИмяЗначения, Знач Обязательный = Ложь)

	ЗначениеПараметра = ЗначенияПараметров.Получить(ИмяЗначения);

	Если ТипЗнч(ЗначениеПараметра) = Тип("Дата") Тогда
		ЗначениеПараметра = Формат(ЗначениеПараметра, "ДФ='yyyy-MM-dd hh:mm:ss'");
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		Если Обязательный Тогда
			ВызватьИсключение СтрШаблон("Не заполнен обязательный параметр %1!", ИмяЗначения);
		Иначе
			Возврат;
		КонецЕсли;
	КонецЕсли;

	ПараметрыЗапуска.Добавить(Новый Структура("Параметр, Значение", ПараметрРАК, ЗначениеПараметра));

КонецПроцедуры // ДобавитьИменованныйПараметр()

// Функция возвращает значение параметра-флага из структуры значений параметров
//   
// Параметры:
//   Имя              - Строка            - имя параметра в структуре значений параметров
//   
// Возвращаемое значение:
//    Булево          - значение флага, если параметр отсутствует в структуре значений параметров,
//                    возвращается Ложь
//
Функция ЗначениеФлага(Знач Имя)

	Параметр = ЗначенияПараметров.Получить(Имя);
	Если Параметр = Неопределено Тогда
		Параметр = Ложь;
	КонецЕсли;

	Возврат Параметр;

КонецФункции // ЗначениеФлага()

#КонецОбласти // СлужебныеПроцедуры
