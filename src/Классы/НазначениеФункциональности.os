// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Требование_Ид;        // rule
Перем Требование_Позиция;    // position
Перем Требование_Свойства;

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера
Перем Сервер_Владелец;

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект, агент кластера
//   Кластер          - Кластер                  - ссылка на родительский объект, кластер
//   Сервер           - Сервер                   - ссылка на родительский объект, сервер
//   Требование       - Строка, Соответствие     - идентификатор требования назначения в кластере 1С
//                                                 или параметры требования назначения
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Сервер, Требование)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Требование) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	Сервер_Владелец = Сервер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент,
	                                        Перечисления.РежимыАдминистрирования.НазначенияФункциональности);

	Если ТипЗнч(Требование) = Тип("Соответствие") Тогда
		Требование_Ид = Требование["rule"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Требование_Свойства, Требование);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Требование_Ид = Требование;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//
// Параметры:
//   РежимОбновления           - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                              0 - обновить данные только по таймеру
//                                             -1 - не обновлять данные
//
Процедура ОбновитьДанные(РежимОбновления = 0) Экспорт

	Если НЕ ТребуетсяОбновление(РежимОбновления) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"   , Сервер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторТребования", Сервер_Владелец.Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения требования назначения функциональности кластера ""%1"",
		                        | КодВозврата = %2:%3%4",
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Требование_Свойства, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Функция признак необходимости обновления данных
//
// Параметры:
//   РежимОбновления           - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                              0 - обновить данные только по таймеру
//                                             -1 - не обновлять данные
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(РежимОбновления = 0) Экспорт

	Возврат Служебный.ТребуетсяОбновление(Требование_Свойства, МоментАктуальности,
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

// Функция возвращает идентификатор требования назначения функциональности
//
// Возвращаемое значение:
//    Строка - идентификатор требования назначения функциональности
//
Функция Ид() Экспорт

	Возврат Требование_Ид;

КонецФункции // Ид()

// Функция возвращает позицию требования назначения функциональности в списке (начиная с 0)
//
// Возвращаемое значение:
//    Строка - позиция требования назначения функциональности в списке
//
Функция Позиция() Экспорт

	Если Служебный.ТребуетсяОбновление(Требование_Позиция, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
	КонецЕсли;

	Возврат Требование_Позиция;
	
КонецФункции // Позиция()

// Функция возвращает значение параметра требования назначения функциональности
//
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра требования назначения функциональности
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//
// Возвращаемое значение:
//    Произвольный - значение параметра требования назначения функциональности
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	Если НЕ Найти("ИД, RULE", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Требование_Ид;
	КонецЕсли;

	Если НЕ Найти("ПОЗИЦИЯ, POSITION", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Требование_Позиция;
	КонецЕсли;
	
	ЗначениеПоля = Требование_Свойства.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Требование_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
	
// Процедура изменяет параметры требования назначения функциональности
//
// Параметры:
//   Позиция                 - Число            - позиция требования назначения функциональности в списке (начиная с 0)
//   ПараметрыТребования     - Структура        - новые параметры требования назначения функциональности
//
Процедура Изменить(Позиция, Знач ПараметрыТребования = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыТребования) = Тип("Структура") Тогда
		ПараметрыТребования = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"     , Сервер_Владелец.Ид());
	ПараметрыКоманды.Вставить("Идентификатортребования"  , Ид());

	ПараметрыКоманды.Вставить("Позиция"        , Позиция);

	Для Каждого ТекЭлемент Из ПараметрыТребования Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка изменения требования назначения функциональности ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Позиция,
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(ВыводКоманды);

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Изменить()

// Процедура удаляет требование назначения функциональности для сервера 1С
//
Процедура Удалить() Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"     , Сервер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторТребования"  , Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Удалить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка удаления требования назначения функциональности ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Получить("Позиция"),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(ВыводКоманды);

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()
