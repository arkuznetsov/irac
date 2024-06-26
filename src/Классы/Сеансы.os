// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера
Перем ИБ_Владелец;

Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем Элементы;            // - ОбъектыКластера   - элементы коллекции объектов кластера
Перем Лицензии;

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                  - ссылка на родительский объект кластера
//   ИБ               - ИнформационнаяБаза       - ссылка на родительский объект информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ = Неопределено)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Владелец = ИБ;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.Сеансы);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);
	Лицензии = Новый Лицензии(Кластер_Агент, Кластер_Владелец, ЭтотОбъект, ИБ_Владелец);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список сеансов от утилиты администрирования кластера 1С
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
	
	Если НЕ ИБ_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторИБ", ИБ_Владелец.Ид());
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения списка сеансов кластера ""%1"", КодВозврата = %2:%3%4",
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	// По какой-то причине сеансы погут быть задублированы поэтому проверяем на дубли
	ДобавленныеСеансы = Новый Соответствие();

	МассивСеансов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Если НЕ ДобавленныеСеансы[ТекОписание["session"]] = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		МассивСеансов.Добавить(Новый Сеанс(Кластер_Агент, Кластер_Владелец, ИБ_Владелец, ТекОписание));
		ДобавленныеСеансы.Вставить(ТекОписание["session"], Истина);
	КонецЦикла;

	Элементы.Заполнить(МассивСеансов);

	Элементы.УстановитьАктуальность();

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

	Возврат Элементы.ТребуетсяОбновление(РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Функция возвращает описание параметров объекта
//
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список сеансов
//
// Параметры:
//   Отбор                    - Структура    - Структура отбора сеансов (<поле>:<значение>)
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список сеансов
//
Функция Список(Отбор = Неопределено, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список сеансов
//
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка сеансов, разделенные ","
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список сеансов
//
Функция ИерархическийСписок(Знач ПоляИерархии, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество сеансов в списке
//
// Возвращаемое значение:
//    Число - количество сеансов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание сеанса кластера 1С
//
// Параметры:
//   Сеанс                   - Строка    - Сеанс в виде <имя информационной базы>:<номер сеанса>
//                                         или идентификатор сеанса
//   РежимОбновления         - Число     - 1 - обновить данные принудительно (вызов RAC)
//                                         0 - обновить данные только по таймеру
//                                        -1 - не обновлять данные
//   КакСоответствие         - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание сеанса 1С
//
Функция Получить(Знач Сеанс, Знач РежимОбновления = 0, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();

	Если Служебный.ЭтоGUID(Сеанс) Тогда
		Отбор.Вставить("session", Сеанс);
	Иначе
		Сеанс = СтрРазделить(Сеанс, ":", Ложь);

		Если Сеанс.Количество() = 1 Тогда
			Если Служебный.ЭтоЧисло(Сеанс[0]) Тогда
				Если ИБ_Владелец = Неопределено Тогда
					Возврат Неопределено;
				КонецЕсли;
				Сеанс.Вставить(0, ИБ_Владелец.Получить("name"));
			Иначе
				Сеанс.Добавить("1");
			КонецЕсли;
		КонецЕсли;

		ИБ = Кластер_Владелец.ИнформационныеБазы().Получить(СокрЛП(Сеанс[0]));

		Отбор.Вставить("infobase"  , ИБ.Ид());
		Отбор.Вставить("session-id", Число(СокрЛП(Сеанс[1])));
	КонецЕсли;

	Сеансы = Элементы.Список(Отбор, РежимОбновления, КакСоответствие);

	Если НЕ ЗначениеЗаполнено(Сеансы) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Сеансы[0];

КонецФункции // Получить()

// Процедура удаляет сеанс
//
// Параметры:
//   Сеанс     - Сеанс, Строка   - Сеанс или номер сеанса в виде <имя информационной базы>:<номер сеанса>
//
Процедура Удалить(Знач Сеанс) Экспорт
	
	Если ТипЗнч(Сеанс) = Тип("Строка") Тогда
		Сеанс = Получить(Сеанс);
	КонецЕсли;

	Сеанс.Завершить();

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()

// Функция возвращает список лицензий сеансов 1С
//
// Возвращаемое значение:
//    ОбъектыКластера - список лицензий сеансов 1С
//
Функция Лицензии() Экспорт
	
	Возврат Лицензии;
	
КонецФункции // Лицензии()
