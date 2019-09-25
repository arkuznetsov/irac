// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Объект_Тип;
Перем Объект_Ид;
Перем Объект_Параметры;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера             - ссылка на родительский объект агента кластера
//   Кластер            - Кластер                   - ссылка на родительский объект кластера
//   ОбъектКластера     - Строка, Соответствие      - идентификатор объекта в кластере 1С или параметры объекта
//   ТипОбъекта         - Перечисления.             - имя типа объекта кластера
//                        РежимыАдминистрирования
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ОбъектКластера, ТипОбъекта)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(ОбъектКластера) Тогда
		Возврат;
	КонецЕсли;

	Объект_Тип = ТипОбъекта;

	ПараметрыОбъекта = Новый КомандыОбъекта(Объект_Тип);
	
	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	Если ТипЗнч(ОбъектКластера) = Тип("Соответствие") Тогда
		ОбъектКластера_Ид = Сервер[ТипОбъекта];
		Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, Объект_Параметры, ОбъектКластера);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Объект_Ид = ОбъектКластера;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = 60000;
	
КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно        - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(Сервер_Параметры,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Описание"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описание объекта, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если МассивРезультатов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, Объект_Параметры, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

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

// Функция возвращает идентификатор сервера 1С
//   
// Возвращаемое значение:
//    Строка - идентификатор сервера 1С
//
Функция ТипОбъекта() Экспорт

	Возврат Объект_Тип;

КонецФункции // ТипОбъекта()

// Функция возвращает идентификатор объекта кластера 1С
//   
// Возвращаемое значение:
//    Строка - идентификатор объекта кластера 1С
//
Функция Ид() Экспорт

	Возврат Объект_Ид;

КонецФункции // Ид()

// Функция возвращает значение параметра объекта кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра объекта кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти(ВРЕг(СтрШаблон("Ид, %1", ОбъектТип)), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Объект_Ид;
	ИначеЕсли НЕ Найти(ВРЕг("Тип, type"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Объект_Тип;
	Иначе
		ЗначениеПоля = Объект_Параметры.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Объект_Параметры.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
