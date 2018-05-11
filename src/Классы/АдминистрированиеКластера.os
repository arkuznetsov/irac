Перем Админ_АдресСервера;
Перем Админ_ПортСервера;
Перем Агент_ИсполнительКоманд;
Перем Агент_Администраторы;
Перем Агент_Администратор;
Перем Кластеры;
Перем Лог;

// Конструктор
//   
// Параметры:
//   АдресСервера			- Строка	- имя сервера агента администрирования (RAS)
//   ПортСервера			- Число		- порт сервера агента администрирования (RAS)
//   ВерсияИлиПутьКРАК		- Строка	- маска версии 1С или путь к утилите RAC
//   Администратор 			- Строка	- администратор агента сервера 1С
//   ПарольАдминистратора 	- Строка	- пароль администратора агента сервера 1С
//
Процедура ПриСозданииОбъекта(АдресСервера
						   , ПортСервера
						   , ВерсияИлиПутьКРАК = "8.3"
						   , Администратор = ""
						   , ПарольАдминистратора = "")

	Админ_АдресСервера = АдресСервера;
	Админ_ПортСервера = ПортСервера;
	
	Агент_ИсполнительКоманд = Новый ИсполнительКоманд(ВерсияИлиПутьКРАК);

	Если ЗначениеЗаполнено(Администратор) Тогда
		Агент_Администратор = Новый Структура("Администратор, Пароль", Администратор, ПарольАдминистратора);
	Иначе
		Агент_Администратор = Неопределено;
	КонецЕсли;
	
	Агент_Администраторы = Новый АдминистраторыАгента(ЭтотОбъект);
	Кластеры = Новый Кластеры(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Функция возвращает строку параметров подключения к агенту администрирования (RAS)
//   
// Возвращаемое значение:
//	Строка - строка параметров подключения к агенту администрирования (RAS)
//
Функция СтрокаПодключения() Экспорт

	Лог.Отладка("Сервер " + Админ_АдресСервера);
	Лог.Отладка("Порт <" + Админ_ПортСервера + ">");

	Сервер = "";
	Если Не ПустаяСтрока(Админ_АдресСервера) Тогда
		Сервер = Админ_АдресСервера;
		Если Не ПустаяСтрока(Админ_ПортСервера) Тогда
			Сервер = Сервер + ":" + Админ_ПортСервера;
		КонецЕсли;
	КонецЕсли;
			
	Возврат Сервер;

КонецФункции // СтрокаПодключения()

// Функция возвращает строку параметров авторизации на агенте кластера 1С
//   
// Возвращаемое значение:
//	Строка - строка параметров авторизации на агенте кластера 1С
//
Функция СтрокаАвторизации() Экспорт
	
	Если НЕ ТипЗнч(Агент_Администратор)  = Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;

	Если НЕ Агент_Администратор.Свойство("Администратор") Тогда
		Возврат "";
	КонецЕсли;

	Лог.Отладка("Администратор " + Агент_Администратор.Администратор);
	Лог.Отладка("Пароль <***>");

	СтрокаАвторизации = "";
	Если Не ПустаяСтрока(Агент_Администратор.Администратор) Тогда
		СтрокаАвторизации = СтрШаблон("--agent-user=%1 --agent-pwd=%2",
									  Агент_Администратор.Администратор,
									  Агент_Администратор.Пароль);
	КонецЕсли;
			
	Возврат СтрокаАвторизации;
	
КонецФункции // СтрокаАвторизации()
	
// Процедура устанавливает параметры авторизации на агенте кластера 1С
//   
// Параметры:
//   Администратор 		- Строка	- администратор агента сервера 1С
//   Пароль			 	- Строка	- пароль администратора агента сервера 1С
//
Процедура УстановитьАдминистратора(Администратор, Пароль) Экспорт

	Агент_Администратор = Новый Структура("Администратор, Пароль", Администратор, Пароль);

КонецПроцедуры // УстановитьАдминистратора()

// Функция возвращает текущий объект-исполнитель команд
//   
// Возвращаемое значение:
//   ИсполнительКоманд		- текущее значение объекта-исполнителя команд
//
Функция ИсполнительКоманд() Экспорт

	Возврат Агент_ИсполнительКоманд;

КонецФункции // ИсполнительКоманд()

// Процедура устанавливает объект-исполнитель команд
//   
// Параметры:
//   НовыйИсполнитель 		- ИсполнительКоманд		- новый объект-исполнитель команд
//
Процедура УстановитьИсполнительКоманд(Знач НовыйИсполнитель = Неопределено) Экспорт

	Если ТипЗнч(НовыйИсполнитель) = Тип("ИсполнительКоманд") Тогда
		Агент_ИсполнительКоманд = НовыйИсполнитель;
	КонецЕсли;

КонецПроцедуры // УстановитьИсполнительКоманд()

// Функция выполняет команду и возвращает код возврата команды
//   
// Параметры:
//   ПараметрыКоманды 		- Массив		- параметры выполнения команды
//
// Возвращаемое значение:
//   Число			 		- Код возврата команды
//
Функция ВыполнитьКоманду(ПараметрыКоманды) Экспорт

	Агент_ИсполнительКоманд.ВыполнитьКоманду(ПараметрыКоманды);

	Возврат Агент_ИсполнительКоманд.КодВозврата();

КонецФункции // ВыполнитьКоманду()

// Функция возвращает вывод команды
//   
// Возвращаемое значение:
//  Строка		- вывод выполненной команды
//
Функция ВыводКоманды() Экспорт

	Возврат Агент_ИсполнительКоманд.ВыводКоманды();

КонецФункции // ВыводКоманды()

// Функция возвращает строку описания подключения к серверу администрирования кластера 1С
//   
// Возвращаемое значение:
//	Строка - описание подключения к серверу администрирования кластера 1С
//
Функция ОписаниеПодключения() Экспорт

	Возврат СокрЛП(Админ_АдресСервера) + ":" + Формат(Админ_ПортСервера, "ЧГ=") +
			" (v." + СокрЛП(Агент_ИсполнительКоманд.ВерсияУтилитыАдминистрирования()) + ")";

КонецФункции // ОписаниеПодключения()

// Функция возвращает список администраторов агента кластера 1С
//   
// Возвращаемое значение:
//	Агент_Администраторы - список администраторов агента кластера 1С
//
Функция Администраторы() Экспорт

	Возврат Агент_Администраторы;

КонецФункции // Администраторы()

// Функция возвращает список кластеров 1С
//   
// Возвращаемое значение:
//	Кластеры - список кластеров 1С
//
Функция Кластеры() Экспорт

	Возврат Кластеры;

КонецФункции // Кластеры()	

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
