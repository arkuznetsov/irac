Перем Процесс_Ид;		// process
Перем Процесс_Сервер;	// host
Перем Процесс_Порт;		// port
Перем Процесс_Параметры;

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Процесс_Соединения;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера			- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер				- Кластера		- ссылка на родительский объект кластера
//   Ид						- Строка		- идентификатор рабочего процесса
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Ид)

	Если НЕ ЗначениеЗаполнено(Ид) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	Процесс_Ид = Ид;

	ПериодОбновления = 60000;
	МоментАктуальности = 0;
	
	Процесс_Соединения		= Новый Соединения(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(Процесс_Параметры,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("process");
	ПараметрыЗапуска.Добавить("info");

	ПараметрыЗапуска.Добавить(СтрШаблон("--process=%1", Процесс_Ид));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	ТекОписание = МассивРезультатов[0];

	Процесс_Сервер = ТекОписание.Получить("host");
	Процесс_Порт = ТекОписание.Получить("port");

	ВремПроцессы = Новый РабочиеПроцессы(Кластер_Агент, Кластер_Владелец);

	СтруктураПараметров = ВремПроцессы.ПолучитьСтруктуруПараметровОбъекта();

	Процесс_Параметры = Новый Соответствие();

	Для Каждого ТекЭлемент Из СтруктураПараметров Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание,
																  ТекЭлемент.Значение.ИмяПоляРАК,
																  ТекЭлемент.Значение.ЗначениеПоУмолчанию); 
		Процесс_Параметры.Вставить(ТекЭлемент.Ключ, ЗначениеПараметра);
	КонецЦикла;

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает идентификатор рабочего процесса 1С
//   
// Возвращаемое значение:
//	Строка - идентификатор рабочего процесса 1С
//
Функция Ид() Экспорт

	Возврат Процесс_Ид;

КонецФункции // Ид()

// Функция возвращает адрес сервера рабочего процесса 1С
//   
// Возвращаемое значение:
//	Строка - адрес сервера рабочего процесса 1С
//
Функция Сервер() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Процесс_Сервер, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Процесс_Сервер;
		
КонецФункции // Сервер()
	
// Функция возвращает порт рабочего процесса 1С
//   
// Возвращаемое значение:
//	Строка - порт рабочего процесса 1С
//
Функция Порт() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Процесс_Порт, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Процесс_Порт;
		
КонецФункции // Порт()
	
// Функция возвращает значение параметра рабочего процесса 1С
//   
// Параметры:
//   ИмяПоля			 	- Строка		- Имя параметра рабочего процесса
//   ОбновитьПринудительно 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Произвольный - значение параметра рабочего процесса 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРЕг("Ид, process"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Процесс_Ид;
	ИначеЕсли НЕ Найти(ВРЕг("Сервер, host"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Процесс_Сервер;
	ИначеЕсли НЕ Найти(ВРЕг("Порт, port"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Процесс_Порт;
	КонецЕсли;
	
	ЗначениеПоля = Процесс_Параметры.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
		
		ВремПроцессы = Новый РабочиеПроцессы(Кластер_Агент, Кластер_Владелец);

		СтруктураПараметров = ВремПроцессы.ПолучитьСтруктуруПараметровОбъекта("ИмяПоляРАК");
		
		ОписаниеПараметра = СтруктураПараметров.Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Процесс_Параметры.Получить(ОписаниеПараметра["ИмяПараметра"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
		
КонецФункции // Получить()
	
// Функция возвращает список соединений рабочего процесса 1С
//   
// Возвращаемое значение:
//	Соединения - список соединений рабочего процесса 1С
//
Функция Соединения() Экспорт
	
	Возврат Процесс_Соединения;
	
КонецФункции // Соединения()
	
Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
