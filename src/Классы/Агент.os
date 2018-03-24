Перем Админ_Сервер;
Перем Админ_Порт;
Перем Версия1С;
Перем ПутьКПлатформе1С;
Перем Агент_Администраторы;
Перем Агент_Администратор;
Перем Кластеры;
Перем Лог;

// Конструктор
//   
// Параметры:
//   Сервер 				- Строка	- имя сервера агента администрирования (RAS)
//   Порт	 				- Число		- порт сервера агента администрирования (RAS)
//   Версия 				- Строка	- маска версии 1С
//   Администратор 			- Строка	- администратор агента сервера 1С
//   ПарольАдминистратора 	- Строка	- пароль администратора агента сервера 1С
//
Процедура ПриСозданииОбъекта(Сервер
						   , Порт
						   , Версия = "8.3"
						   , Администратор = ""
						   , ПарольАдминистратора = "")

	Админ_Сервер = Сервер;
	Админ_Порт = Порт;
	
	ПутьКПлатформе1С = Служебный.ПолучитьПутьКВерсииПлатформы(Версия);
	Версия1С = Служебный.ВерсияПлатформы(ПутьКПлатформе1С);
	
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

	Лог.Отладка("Сервер " + Админ_Сервер);
	Лог.Отладка("Порт <" + Админ_Порт + ">");

	Сервер = "";
	Если Не ПустаяСтрока(Админ_Сервер) Тогда
		Сервер = Админ_Сервер;
		Если Не ПустаяСтрока(Админ_Порт) Тогда
			Сервер = Сервер + ":" + Админ_Порт;
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

// Функция возвращает строку описания подключения к серверу администрирования кластера 1С
//   
// Возвращаемое значение:
//	Строка - описание подключения к серверу администрирования кластера 1С
//
Функция ОписаниеПодключения() Экспорт

	Возврат СокрЛП(Админ_Сервер) + ":" + Формат(Админ_Порт, "ЧГ=") + "(v." + СокрЛП(Версия1С) + ")";

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
Функция Кластеры(ОбновитьДанные = Ложь) Экспорт

	Возврат Кластеры;

КонецФункции // Кластеры()	

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
