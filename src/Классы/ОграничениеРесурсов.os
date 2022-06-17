// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Ограничение_Имя;
Перем Ограничение_Свойства;
Перем Ограничение_ДлительностьСбора;
Перем Ограничение_Значения;

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//   
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                  - ссылка на родительский объект кластера
//   Ограничение      - Строка, Соответствие     - имя ограничения потребления ресурсов в кластере 1С
//                                                 или параметры ограничения потребления ресурсов
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Ограничение)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Ограничение) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.ОграниченияРесурсов);

	Кластер_Агент    = АгентКластера;
	Кластер_Владелец = Кластер;

	Если ТипЗнч(Ограничение) = Тип("Соответствие") Тогда
		Ограничение_Имя = Ограничение["name"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Ограничение_Свойства, Ограничение);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Ограничение_Имя = Ограничение;
		МоментАктуальности = 0;
	КонецЕсли;
	
	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
	Ограничение_Значения = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   
Процедура ОбновитьДанные(РежимОбновления = 0) Экспорт

	Если НЕ ТребуетсяОбновление(РежимОбновления) Тогда
		 Возврат;
	 КонецЕсли;
 
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИмяОграничения", Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	
	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения описания ограничения потребления ресурсов ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Ограничение_Свойства, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(РежимОбновления = 0) Экспорт

	Возврат Служебный.ТребуетсяОбновление(Ограничение_Свойства, МоментАктуальности,
	                                      ПериодОбновления, РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Функция возвращает описание параметров объекта
//   
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает имя ограничения потребления ресурсов
//   
// Возвращаемое значение:
//    Строка - имя ограничения потребления ресурсов
//
Функция Имя() Экспорт

	Возврат Ограничение_Имя;

КонецФункции // Имя()

// Функция возвращает значения ограничения потребления ресурсов
//   
// Возвращаемое значение:
//    ОбъектыКластера - имя ограничения потребления ресурсов
//
Функция Значения() Экспорт

	Возврат Ограничение_Значения;

КонецФункции // Значения()

// Функция возвращает значение параметра ограничения потребления ресурсов кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Произвольный - значение параметра ограничения потребления ресурсов кластера 1С
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	ЗначениеПоля = Неопределено;
	
	Если НЕ Найти("ИМЯ, NAME", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Ограничение_Имя;
	ИначеЕсли НЕ Найти("ЗНАЧЕНИЯ, VALUES", ВРег(ИмяПоля)) = 0 Тогда
		ЗначениеПоля = Ограничение_Значения;
	Иначе
		ЗначениеПоля = Ограничение_Свойства.Получить(ИмяПоля);
	КонецЕсли;

	Если ЗначениеПоля = Неопределено Тогда
	
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Ограничение_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	
	КонецЕсли;

	Возврат ЗначениеПоля;
	
КонецФункции // Получить()

// Процедура изменяет параметры ограничения потребления ресурсов
//   
// Параметры:
//   ПараметрыОграничения      - Структура        - новые параметры ограничения потребления ресурсов
//
Процедура Изменить(Знач ПараметрыОграничения = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыОграничения) = Тип("Соответствие") Тогда
		ПараметрыОграничения = Новый Соответствие();
	КонецЕсли;
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("ИмяОграничения"           , Имя());
	
	Для Каждого ТекЭлемент Из ПараметрыОграничения Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");
	
	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка изменения параметров ограничения потребления ресурсов ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));
	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Изменить()

// Процедура удаляет ограничение потребления ресурсов из кластера 1С
//
Процедура Удалить() Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИмяОграничения"              , Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Отключить");
	
	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка удаления ограничения потребления ресурсов ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Имя(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        Кластер_Агент.ВыводКоманды(Ложь));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	
КонецПроцедуры // Удалить()
