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
Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера
Перем Элементы;            // - ОбъектыКластера   - элементы коллекции объектов кластера

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                  - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.ПрофилиБезопасности);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список профилей безопасности от утилиты администрирования кластера 1С
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
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка получения списка профилей безопасности кластера ""%1"",
		                        | КодВозврата = %2:%3%4",
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивПрофилей = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивПрофилей.Добавить(Новый ПрофильБезопасности(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивПрофилей);

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

// Функция возвращает список профилей безопасности кластера 1С
//
// Параметры:
//   Отбор                    - Структура    - Структура отбора профилей безопасности (<поле>:<значение>)
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
//    Массив - список профилей безопасности кластера 1С
//
Функция Список(Отбор = Неопределено, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список профилей безопасности кластера 1С
//
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка профилей безопасности,
//                                             разделенные ","
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
//    Соответствие - список профилей безопасности кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список профилей безопасности
//                                                                        или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество профилей безопасности в списке
//
// Возвращаемое значение:
//    Число - количество профилей безопасности
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание профиля безопасности кластера 1С
//
// Параметры:
//   ИмяИлиИд                - Строка    - Имя или идентификатор профиля безопасности
//   РежимОбновления         - Число     - 1 - обновить данные принудительно (вызов RAC)
//                                         0 - обновить данные только по таймеру
//                                        -1 - не обновлять данные
//   КакСоответствие         - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание профиля безопасности кластера 1С
//
Функция Получить(Знач ИмяИлиИд, Знач РежимОбновления = 0, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();

	Если Служебный.ЭтоGUID(ИмяИлиИд) Тогда
		Отбор.Вставить("profile", ИмяИлиИд);
	Иначе
		Отбор.Вставить("name", ИмяИлиИд);
	КонецЕсли;

	СписокПрофилей = Элементы.Список(Отбор, РежимОбновления, КакСоответствие);
	
	Если НЕ ЗначениеЗаполнено(СписокПрофилей) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокПрофилей[0];

КонецФункции // Получить()

// Процедура добавляет новый профиль безопасности в кластер 1С
//
// Параметры:
//   Имя                 - Строка        - имя профиля безопасности 1С
//   ПараметрыПрофиля     - Структура        - параметры профиля безопасности 1С
//
Процедура Добавить(Имя, ПараметрыПрофиля = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыПрофиля) = Тип("Структура") Тогда
		ПараметрыПрофиля = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("Имя"            , Имя);

	Для Каждого ТекЭлемент Из ПараметрыПрофиля Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка добавления профиля безопасности ""%1"" кластера ""%2"",
		                        | КодВозврата = %3:%4%5",
		                        Имя,
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Лог.Отладка(ВыводКоманды);

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Добавить()

// Процедура удаляет профиль безопасности из кластера 1С
//
// Параметры:
//   Имя            - Строка    - Имя профиля безопасности
//
Процедура Удалить(Имя) Экспорт
	
	Профиль = Получить(Имя);

	Если Профиль = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Профиль.Удалить();

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()
