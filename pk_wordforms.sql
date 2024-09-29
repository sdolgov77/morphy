CREATE OR REPLACE PACKAGE pk_wordforms IS
  -- Author  : NEGRIYNP
  -- Created : 30.03.2018
  -- Purpose : API словоформ
  --
  -- Пол
  c_female          CONSTANT PLS_INTEGER := 0;                -- Женский
  c_male            CONSTANT PLS_INTEGER := 1;                -- Мужской
  c_neuter          CONSTANT PLS_INTEGER := 2;                -- Средний
  --
  -- Константы модификации первой буквы фразы
  c_init_upper      CONSTANT VARCHAR2(16) := 'init_upper';    -- Приводить первую букву к верхнему регистру
  c_init_lower      CONSTANT VARCHAR2(16) := 'init_lower';    -- Приводить первую букву к нижнему регистру
  c_init_as_is      CONSTANT VARCHAR2(16) := 'init_as_is';    -- Выводить как есть
  --
  -- Константы вывода вежливого обращения
  c_respected_male   CONSTANT VARCHAR2(16) := 'Уважаемый';    -- Вежливое обращение к мужчине
  c_respected_female CONSTANT VARCHAR2(16) := 'Уважаемая';    -- Вежливое обращение к женщине
  --
  -- Падежи
  c_nominative      CONSTANT PLS_INTEGER := 1;                -- Именительный
  c_genitive        CONSTANT PLS_INTEGER := 2;                -- Родительный
  c_dative          CONSTANT PLS_INTEGER := 3;                -- Дательный
  c_accusative      CONSTANT PLS_INTEGER := 4;                -- Винительный
  c_instrumental    CONSTANT PLS_INTEGER := 5;                -- Творительный
  c_prepositional   CONSTANT PLS_INTEGER := 6;                -- Предложный
  --
  -- Режимы длины имени
  c_short           CONSTANT VARCHAR2(16) := 'short';           -- Фамилия И.О.
  c_reverse_short   CONSTANT VARCHAR2(16) := 'reverse_short';   -- И.О. Фамилия
  c_long            CONSTANT VARCHAR2(16) := 'long';            -- Фамилия Имя Отчество
  c_respected_long  CONSTANT VARCHAR2(16) := 'respected_long';  -- Уважаемый Фамилия Имя Отчество
  c_respected_short CONSTANT VARCHAR2(16) := 'respected_short'; -- Уважаемый Имя Отчество
  --
  -- Режимы вывода даты
  c_add_short_year  CONSTANT VARCHAR2(16) := 'add_short_year';  -- Дописывать " г." в конце даты
  c_add_long_year   CONSTANT VARCHAR2(16) := 'add_long_year';   -- Дописывать " года" в конце даты
  --
  -- Формат дня месяца
  c_day_short       CONSTANT VARCHAR2(16) := 'short';         -- Опускать ведущий 0
  c_day_long        CONSTANT VARCHAR2(16) := 'long';          -- Выводить ведущий 0
  --
  -- Режимы вывода должности
  c_post_as_is      CONSTANT VARCHAR2(16) := 'post_as_is';      -- Должность как есть
  c_post            CONSTANT VARCHAR2(16) := 'post';            -- Сокращенный вариант должности
  c_post_dept       CONSTANT VARCHAR2(16) := 'post_dept';       -- Сокращенный вариант должности с кратким именем подразделения
  c_post_long_dept  CONSTANT VARCHAR2(16) := 'post_long_dept';  -- Сокращенный вариант должности с полным именем подраздаления
  c_post_possible   CONSTANT VARCHAR2(16) := 'post_possible';   -- Максимально возможную информацию на основе предоставленных данных
  --
  -- Значения входных параметров по умолчанию
  dflt_case         CONSTANT PLS_INTEGER  := c_nominative;      -- Падеж по умолчанию
  dflt_post         CONSTANT VARCHAR2(16) := c_post_possible;   -- Режим вывода должности по умолчанию
  dflt_length       CONSTANT VARCHAR2(16) := c_long;            -- Режим длины по умолчанию
  dflt_date         CONSTANT VARCHAR2(16) := c_add_short_year;  -- Режим даты по умолчанию
  dflt_day          CONSTANT VARCHAR2(16) := c_day_short;       -- Дописывать " года" в конце даты
  dflt_curr_code    CONSTANT curency.charcode%TYPE := 'RUR';    -- Код валюты по умолчанию
  dflt_init_dept    CONSTANT VARCHAR2(16) := c_init_lower;      -- Режим вывода первой буквы подразделения по умолчанию
  --
  -- Режимы вывода количества
  c_count_digital   CONSTANT VARCHAR2(16) := 'digital';       -- Вывод количества числом
  c_count_text      CONSTANT VARCHAR2(16) := 'text';          -- Вывод количества текстом
  --
  c_pttrn_count     CONSTANT CHAR(2) := '%s';                 -- Паттерн замены количества
  --
  -- Исключения и коды ошибок
  no_dept           EXCEPTION;  -- Нет данных подразделения
  ec_no_dept        CONSTANT NUMBER := '-20200';
  PRAGMA EXCEPTION_INIT(no_dept,        -20200);
  --
  ------- Процедуры и функции, расположенные далее, не рекомендуется использовать в своих пакетах
  --
  PROCEDURE check_phrase_case (
  -- Корректность падежа
    phrase_case     IN     NUMBER                             -- Падеж
  );
  --
  PROCEDURE check_regime_length (
  -- Корректность режима длины имени
    regime          IN     VARCHAR2                           -- Режим
  );
  --
  PROCEDURE check_regime_post (
  -- Корректность режима вывода должности
    regime          IN     VARCHAR2                           -- Режим
  );
  --
  FUNCTION fio (
  -- Cклонение Фамилии Имени Отчества
    last_name       IN     VARCHAR2,                          -- Фамилия
    first_name      IN     VARCHAR2,                          -- Имя
    middle_name     IN     VARCHAR2,                          -- Отчество
    sex             IN     NUMBER,                            -- Пол
    phrase_case     IN     NUMBER DEFAULT dflt_case,          -- Падеж
    regime_length   IN     VARCHAR2 DEFAULT dflt_length       -- Режим длины
  ) RETURN          VARCHAR2;
  --
  FUNCTION fio (
  -- Cклонение Фамилии Имени Отчества
    full_name       IN     VARCHAR2,                          -- Фамилия Имя Отчество
    sex             IN     NUMBER DEFAULT NULL,               -- Пол
    phrase_case     IN     NUMBER DEFAULT dflt_case,          -- Падеж
    regime_length   IN     VARCHAR2 DEFAULT dflt_length       -- Режим длины
  ) RETURN          VARCHAR2;
  --
  FUNCTION post (
  -- Склонение должности в подразделении
    post_name         IN     VARCHAR2,                        -- Должность
    post_suffix       IN     VARCHAR2 DEFAULT NULL,           -- Расширение должности
    dept_long_name    IN     VARCHAR2 DEFAULT NULL,           -- Полное наименование подразделения
    dept_name         IN     VARCHAR2 DEFAULT NULL,           -- Краткое наименование подразделения
    phrase_case       IN     NUMBER DEFAULT dflt_case,        -- Падеж должности
    regime_post       IN     VARCHAR2 DEFAULT dflt_post,      -- Режим вывода должности
    regime_init_dept  IN     VARCHAR2 DEFAULT dflt_init_dept  -- Режим вывода первой буквы подразделения
  ) RETURN            VARCHAR2;
  --
  FUNCTION dept (
  -- Склонение подразделения
    dept_name       IN     VARCHAR2,                          -- Наименование подразделения
    phrase_case     IN     NUMBER DEFAULT dflt_case,          -- Падеж
    regime_init     IN     VARCHAR2 DEFAULT c_init_as_is      -- Режим вывода первой буквы подразделения
  ) RETURN          VARCHAR2;
  --
  FUNCTION dept_init (
  -- Модификация первой буквы наименования подразделения
    dept_name       IN     VARCHAR2,                       -- Наименование подразделения
    regime_init     IN     VARCHAR2 DEFAULT dflt_init_dept -- Режим вывода первой буквы подразделения
  ) RETURN          VARCHAR2;
  --
  FUNCTION dept_init_lower (
  -- Привести первую букву наименования подразделения к нижнему регистру
    dept_name       IN     VARCHAR2                           -- Наименование подразделения
  ) RETURN          VARCHAR2;
  --
  PROCEDURE cut_post (
  -- Сокращение должности
    post_name       IN OUT VARCHAR2,                          -- Должность
    dept_long_name  IN     VARCHAR2 DEFAULT NULL              -- Полное наименование подразделения
  );
  --
  FUNCTION phrase (
  -- Склонение текста
    text            IN     VARCHAR2,                          -- Текст
    phrase_case     IN     NUMBER                             -- Падеж
  ) RETURN          VARCHAR2;
  --  
  ------- Функции, расположенные далее, можно использовать в других пакетах
  --
  FUNCTION init_lower (
  -- Привести первую букву текста к нижнему регистру
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2;
  --
  FUNCTION init_upper (
  -- Привести первую букву текста к верхнему регистру
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2;
  --
  FUNCTION print_date (
  -- Печать даты
    p_date          IN     DATE DEFAULT NULL,                 -- Дата
    regime          IN     VARCHAR2 DEFAULT dflt_date,        -- Режим вывода даты
    regime_day      IN     VARCHAR2 DEFAULT dflt_day          -- Режим вывода дня месяца
  ) RETURN          VARCHAR2;
  --
  FUNCTION print_count (
  -- Печать количества
    p_cnt           IN     NUMBER,                            -- Количество
    sex             IN     VARCHAR2                           -- Пол единицы измерения
  ) RETURN          VARCHAR2;
  --
  FUNCTION print_count (
  -- Печать количества
    p_cnt           IN     NUMBER,                            -- Количество
    pttrn_one       IN     VARCHAR2,                          -- Шаблон количества, заканчивающегося на 1, исключая 11 (пр. '%s файл' - именительный падеж, ед.ч.)
    pttrn_two       IN     VARCHAR2,                          -- Шаблон количества, заканчивающегося на 2..4, исключая 12..14 (пр. '%s файла' - родительный падеж, ед.ч)
    pttrn_five      IN     VARCHAR2,                          -- Шаблон количества, заканчивающегося на 0, 5..9, 11..14, (пр. '%s файлов' - родительный падеж, мн.ч.)
    pttrn_null      IN     VARCHAR2 := NULL,                  -- Шаблон неопределенного количества (пр. 'ошибка получения') - если содержит %s в этом месте будет 0
    pttrn_only_zero IN     VARCHAR2 := NULL,                  -- Шаблон для нулевого количества (пр. '%s файлов' - именительный падеж, ед.ч.) - если не заполнить, будет выведена пустая строка
    pttrn_only_one  IN     VARCHAR2 := NULL,                  -- Шаблон единичного количества (пр. '%s файл' - именительный падеж, ед.ч.) - если не заполнить, будет pttrn_one 
    sex             IN     NUMBER   := NULL,                  -- Пол единицы измерения: если указан, будет вывод числа в текстовом виде
    regime_init     IN     VARCHAR2 := NULL                   -- Режим вывода первой буквы
  ) RETURN          VARCHAR2;
  --
  FUNCTION print_sum (
  -- Печать денежной суммы
    p_sum           IN     NUMBER DEFAULT NULL,                           -- Сумма
    currency_code   IN     curency.charcode%TYPE DEFAULT dflt_curr_code,  -- Код валюты
    regime_init     IN     VARCHAR2 := c_init_upper                       -- Режим вывода первой буквы
  ) RETURN          VARCHAR2;
  --
  FUNCTION upper (
  -- Приведение предложения к верхнему регистру, исключая аббревиатуры и разряды
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2;
END pk_wordforms;
/
CREATE OR REPLACE PACKAGE BODY pk_wordforms IS
  --
  FUNCTION fio_stub (
    last_name       IN     VARCHAR2,                          -- Фамилия
    first_name      IN     VARCHAR2,                          -- Имя
    middle_name     IN     VARCHAR2,                          -- Отчество
    sex             IN     NUMBER,                            -- Пол
    phrase_case     IN     NUMBER,                            -- Падеж
    is_cut          IN     NUMBER,                            -- Инициалы вместо имени отчества
    is_reverse      IN     NUMBER                             -- Реверсный вывод (Фамилия после инициалов)
  ) RETURN          VARCHAR2
  IS LANGUAGE JAVA NAME '
WordForms.getFIO (
  java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.Integer,
  int,
  java.lang.Integer,
  java.lang.Integer
) return java.lang.String
'
  ;
  --
  FUNCTION fio_stub (
    full_name       IN     VARCHAR2,                          -- Фамилия Имя Отчество
    sex             IN     NUMBER,                            -- Пол
    phrase_case     IN     NUMBER,                            -- Падеж
    is_cut          IN     NUMBER,                            -- Инициалы вместо имени отчества
    is_reverse      IN     NUMBER                             -- Реверсный вывод (Фамилия после инициалов)
  ) RETURN          VARCHAR2
  IS LANGUAGE JAVA NAME '
WordForms.getFIOP (
  java.lang.String,
  java.lang.Integer,
  int,
  java.lang.Integer,
  java.lang.Integer
) return java.lang.String
'
  ;
  --
  FUNCTION post_stub (
    post_name       IN     VARCHAR2,                          -- Должность
    phrase_case     IN     NUMBER                             -- Падеж
  ) RETURN          VARCHAR2
  IS LANGUAGE JAVA NAME '
WordForms.getAppointment (
  java.lang.String,
  int
) return java.lang.String
'
  ;
  --
  FUNCTION dept_stub (
    dept_name       IN     VARCHAR2,                          -- Подразделение
    phrase_case     IN     NUMBER                             -- Падеж
  ) RETURN          VARCHAR2
  IS LANGUAGE JAVA NAME '
WordForms.getOffice (
  java.lang.String,
  int
) return java.lang.String
'
  ;
  --
  FUNCTION upper_stub (
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2
  IS LANGUAGE JAVA NAME '
WordForms.upper (
  java.lang.String
) return java.lang.String
'
  ;
  --
  FUNCTION upper (
  -- Приведение предложения к верхнему регистру, исключая аббревиатуры и разряды
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2
  IS
  BEGIN
    IF trim(text) IS NULL THEN
      RETURN NULL;
    ELSE
      RETURN upper_stub(text);
    END IF;
  END;
  --
  PROCEDURE check_phrase_case (
  -- Корректность падежа
    phrase_case     IN     NUMBER                             -- Падеж
  )
  IS
  BEGIN
    IF trim(phrase_case) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан падеж!');
    END IF;
    IF phrase_case NOT IN (
                c_nominative,
                c_genitive,
                c_dative,
                c_accusative,
                c_instrumental,
                c_prepositional
              )
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан падеж!');
    END IF;
  END;
  --
  PROCEDURE check_regime_init (
  -- Корректность режима вывода первой буквы
    regime          IN     VARCHAR2                           -- Режим
  )
  IS
  BEGIN
    IF trim(regime) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода первой буквы!');
    END IF;
    IF regime NOT IN (
                c_init_upper,
                c_init_lower,
                c_init_as_is
              )
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода первой буквы!');
    END IF;
  END;
  --
  PROCEDURE check_regime_init_dept (
  -- Корректность режима вывода первой буквы подразделения
    regime          IN     VARCHAR2                           -- Режим
  )
  IS
  BEGIN
    IF trim(regime) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода первой буквы подразделения!');
    END IF;
    IF regime NOT IN (
                c_init_lower,
                c_init_as_is
              )
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода первой буквы подразделения!');
    END IF;
  END;
  --
  PROCEDURE check_regime_length (
  -- Корректность режима длины имени
    regime          IN     VARCHAR2                           -- Режим
  )
  IS
  BEGIN
    IF trim(regime) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода имени!');
    END IF;
    IF regime NOT IN (
                c_short,
                c_reverse_short,
                c_long,
                c_respected_long,
                c_respected_short
              )
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода имени!');
    END IF;
  END;
  --
  PROCEDURE check_regime_post (
  -- Корректность режима вывода должности
    regime          IN     VARCHAR2                           -- Режим
  )
  IS
  BEGIN
    IF trim(regime) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода должности!');
    END IF;
    IF regime NOT IN (
                c_post_possible,
                c_post_as_is,
                c_post,
                c_post_dept,
                c_post_long_dept
              )
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода должности!');
    END IF;
  END;
  --
  PROCEDURE check_regime_respected (
  -- Корректность режима вывода вежливого обращения
    regime          IN     VARCHAR2                           -- Режим
  )
  IS
  BEGIN
    IF trim(regime) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода вежливого обращения!');
    END IF;
    IF regime NOT IN (0, 1) THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода вежливого обращения!');
    END IF;
  END;
  --
  FUNCTION get_cut (
    regime_length   IN     VARCHAR2                           -- Режим
  ) RETURN          VARCHAR2
  IS
  BEGIN
    check_regime_length(regime_length);
    CASE regime_length
      WHEN c_reverse_short THEN
        RETURN 1;
      WHEN c_short THEN
        RETURN 1;
      WHEN c_long THEN
        RETURN 0;
      WHEN c_respected_long THEN
        RETURN 0;
      WHEN c_respected_short THEN
        RETURN 0;
    END CASE;
  END;
  --
  FUNCTION get_reverse (
    regime_length   IN     VARCHAR2                           -- Режим
  ) RETURN          VARCHAR2
  IS
  BEGIN
    check_regime_length(regime_length);
    CASE regime_length
      WHEN c_reverse_short THEN
        RETURN 1;
      WHEN c_short THEN
        RETURN 0;
      WHEN c_long THEN
        RETURN 0;
      WHEN c_respected_long THEN
        RETURN 0;
      WHEN c_respected_short THEN
        RETURN 0;
    END CASE;
  END;
  --
  PROCEDURE check_sex (
  -- Корректность пола
    sex             IN     VARCHAR2                           -- Пол
  )
  IS
  BEGIN
    IF sex NOT IN (
                c_male,
                c_female
              )
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан пол!');
    END IF;
  END;
  --
  FUNCTION phrase (
  -- Склонение текста
    text            IN     VARCHAR2,                          -- Текст
    phrase_case     IN     NUMBER                             -- Падеж
  ) RETURN          VARCHAR2
  IS
  BEGIN
    IF phrase_case = c_nominative THEN
      RETURN text;
    ELSE
      RETURN post_stub (text, phrase_case);
    END IF;
  END;
  --
  FUNCTION prefix_fio (
  -- Обращение перед ФИО
    sex             IN     NUMBER,                            -- Пол
    phrase_case     IN     NUMBER,                            -- Падеж
    regime_length   IN     VARCHAR2                           -- Режим длины
  ) RETURN          VARCHAR2
  IS
  BEGIN
   IF regime_length IN (c_respected_short, c_respected_long) THEN
     IF sex = 0 THEN
       RETURN pk_wordforms.phrase(
                text => c_respected_female,
                phrase_case => phrase_case
              )||' ';
     ELSIF sex = 1 THEN
       RETURN pk_wordforms.phrase(
                text => c_respected_male,
                phrase_case => phrase_case
              )||' ';
     END IF;
   END IF;    
   RETURN NULL;
  END;
  --
  FUNCTION fio (
  -- Cклонение Фамилии Имени Отчества
    last_name       IN     VARCHAR2,                          -- Фамилия
    first_name      IN     VARCHAR2,                          -- Имя
    middle_name     IN     VARCHAR2,                          -- Отчество
    sex             IN     NUMBER,                            -- Пол
    phrase_case     IN     NUMBER DEFAULT dflt_case,          -- Падеж
    regime_length   IN     VARCHAR2 DEFAULT dflt_length       -- Режим длины
  ) RETURN          VARCHAR2
  IS 
  BEGIN
    check_sex(sex);
    check_phrase_case(phrase_case);
    RETURN prefix_fio (
             sex => sex,
             phrase_case => phrase_case,
             regime_length => regime_length
           )||
           LTRIM(
             fio_stub (
               last_name => CASE WHEN regime_length != c_respected_short THEN last_name END,
               first_name => first_name,
               middle_name => middle_name,
               sex => sex,
               phrase_case => phrase_case,
               is_cut => get_cut(regime_length),
               is_reverse => get_reverse(regime_length)
             )
           );
  END;
  --
  FUNCTION fio (
  -- Cклонение Фамилии Имени Отчества
    full_name       IN     VARCHAR2,                          -- Фамилия Имя Отчество
    sex             IN     NUMBER DEFAULT NULL,               -- Пол
    phrase_case     IN     NUMBER DEFAULT dflt_case,          -- Падеж
    regime_length   IN     VARCHAR2 DEFAULT dflt_length       -- Режим длины
  ) RETURN          VARCHAR2
  IS
    l_regime_length VARCHAR2(512) := NVL(trim(regime_length), c_short);
  BEGIN
    check_sex(sex);
    check_phrase_case(phrase_case);
    IF l_regime_length = c_respected_short THEN
      IF phrase_case = c_nominative THEN
        RETURN prefix_fio (
                 sex => sex,
                 phrase_case => phrase_case,
                 regime_length => regime_length
               )||
               regexp_substr(full_name, '\S+', 1, 2)||' '||
               regexp_substr(full_name, '\S+', 1, 3);
      ELSE
        RETURN fio (
          last_name => regexp_substr(full_name, '\S+', 1, 1),
          first_name => regexp_substr(full_name, '\S+', 1, 2),
          middle_name => regexp_substr(full_name, '\S+', 1, 3),
          sex => sex,
          phrase_case => phrase_case,
          regime_length => regime_length
        );
      END IF;
    ELSIF phrase_case = c_nominative AND l_regime_length IN (c_long, c_respected_long)
       OR trim(full_name) IS NULL
    THEN
      RETURN prefix_fio (
               sex => sex,
               phrase_case => phrase_case,
               regime_length => regime_length
             )||
             full_name;
    ELSE
      RETURN prefix_fio (
               sex => sex,
               phrase_case => phrase_case,
               regime_length => regime_length
             )||
             fio_stub (
               full_name => full_name,
               sex => sex,
               phrase_case => phrase_case,
               is_cut => get_cut(regime_length),
               is_reverse => get_reverse(regime_length)
             );
    END IF;
  END;
  --
  FUNCTION cutted_post (
  -- Может ли наименование должности сокращено
    post_name       IN     VARCHAR2                           -- Наименование должности
  ) RETURN          BOOLEAN
  IS
    l_post_name VARCHAR2(32767) := trim(post_name);
  BEGIN
    IF l_post_name IS NOT NULL THEN
      FOR i IN (
        SELECT
          t.post
        FROM
          wordforms_excl t
        ORDER BY
          t.dept DESC
      ) LOOP
        IF instr(post_name, i.post) > 0 THEN
          RETURN TRUE;
        END IF;
      END LOOP;
    END IF;
    RETURN FALSE;
  END;
  --
  PROCEDURE cut_post (
  -- Сокращение должности
    post_name       IN OUT VARCHAR2,                          -- Должность
    dept_long_name  IN     VARCHAR2 DEFAULT NULL              -- Полное наименование подразделения
  )
  IS
    l_dept_name VARCHAR2(32767) := trim(lower(dept_long_name));
    FUNCTION is_null RETURN BOOLEAN
    IS
    BEGIN
      RETURN trim(l_dept_name) IS NULL OR trim(post_name) IS NULL;
    END;
  BEGIN
    post_name := trim(post_name);
    IF is_null THEN
      RETURN;
    END IF;
    FOR i IN (
      SELECT
        t.dept,
        t.post
      FROM
        wordforms_excl t
      ORDER BY
        t.dept DESC
    ) LOOP
      IF instr(l_dept_name, i.dept) > 0 AND instr(post_name, i.post) > 0 THEN
        l_dept_name := replace(l_dept_name, i.dept);
        post_name := replace(post_name, i.post);
      END IF;
      IF is_null THEN
        post_name := trim(post_name);
        EXIT;
      END IF;
    END LOOP;
  END;
  --
  FUNCTION correct_dept_name (
    dept_name       IN     VARCHAR2
  ) RETURN VARCHAR2
  IS
  BEGIN
    IF instr(dept_name, '"-"') > 0 THEN
      RETURN REPLACE (dept_name, '"-"', '" - "');
    END IF;
    RETURN dept_name;
  END;
  --
  FUNCTION dept (
  -- Склонение подразделения
    dept_name       IN     VARCHAR2,                          -- Подразделение
    phrase_case     IN     NUMBER DEFAULT dflt_case,          -- Падеж
    regime_init     IN     VARCHAR2 DEFAULT c_init_as_is      -- Режим вывода первой буквы подразделения
  ) RETURN          VARCHAR2
  IS 
  BEGIN
    check_phrase_case(phrase_case);
    IF trim(dept_name) IS NULL THEN
      RETURN NULL;
    END IF;
    --
    IF phrase_case = c_nominative
       OR trim(dept_name) IS NULL
       OR phrase_case = c_genitive AND (substr(dept_name, 1, 3) = 'УС ' OR instr(lower(dept_name), 'узел связи') > 0)
    THEN
      RETURN dept_init (
               dept_name => correct_dept_name(dept_name),
               regime_init => regime_init
             );
    END IF;
    --
    RETURN correct_dept_name (
             dept_stub (
               dept_name => dept_init (
                              dept_name =>  dept_name,
                              regime_init => regime_init
                            ),
               phrase_case => phrase_case
             )
           );
  END;
  --
  FUNCTION init_lower (
  -- Привести первую букву текста к нижнему регистру
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2
  IS
  BEGIN
    RETURN lower(substr(text, 1, 1))||substr(text, 2);
  END;
  --
  FUNCTION init_upper (
  -- Привести первую букву текста к верхнему регистру
    text            IN     VARCHAR2                           -- Текст
  ) RETURN          VARCHAR2
  IS
  BEGIN
    RETURN upper(substr(text, 1, 1))||substr(text, 2);
  END;
  --
  FUNCTION dept_init (
  -- Модификация первой буквы наименования подразделения
    dept_name       IN     VARCHAR2,                          -- Наименование подразделения
    regime_init     IN     VARCHAR2 DEFAULT dflt_init_dept    -- Режим вывода первой буквы подразделения
  ) RETURN          VARCHAR2
  IS
  BEGIN
    check_regime_init_dept(regime_init);
    CASE
      WHEN regime_init = c_init_as_is THEN
        RETURN dept_name;
      WHEN length(dept_name) < 2
           OR instr(dept_name, 'цех электросвязи') > 0
           OR instr(dept_name, 'ЦЭС') > 0
           OR instr(dept_name, 'узел связи') > 0
           OR substr(dept_name, 1, 2) = 'УС '
           OR instr(dept_name, ' УС') > 0
           OR substr(upper(dept_name), 0, 15) = 'СВЯЗЬТРАНСНЕФТЬ'
           OR substr(dept_name, 1, 2) = 'АО'
           OR upper(substr(dept_name, 1, 2)) = substr(dept_name, 1, 2)
           OR upper(substr(dept_name, 1, 1)) = substr(dept_name, 1, 1) AND upper(substr(dept_name, 3, 1)) = substr(dept_name, 3, 1)
           OR (
             instr(dept_name, ' ПТУС') > 0
             OR instr(dept_name, 'ПТУС ') > 0
           ) AND upper(substr(dept_name, 1, 6)) != 'ФИЛИАЛ'
      THEN
        RETURN dept_name;
      WHEN regime_init = c_init_lower THEN
        RETURN init_lower(dept_name);
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода первой буквы подразделения!');
    END CASE;
  END;
  --
  FUNCTION dept_init_lower (
  -- Привести первую букву наименования подразделения к нижнему регистру
    dept_name       IN     VARCHAR2                           -- Наименование подразделения
  ) RETURN          VARCHAR2
  IS
  BEGIN
    RETURN pk_wordforms.dept_init (
             dept_name => dept_name,
             regime_init => c_init_lower
           );
  END;
  --
  FUNCTION post (
  -- Склонение должности в подразделении
    post_name         IN     VARCHAR2,                        -- Должность
    post_suffix       IN     VARCHAR2 DEFAULT NULL,           -- Расширение должности
    dept_long_name    IN     VARCHAR2 DEFAULT NULL,           -- Полное наименование подразделения
    dept_name         IN     VARCHAR2 DEFAULT NULL,           -- Краткое наименование подразделения
    phrase_case       IN     NUMBER   DEFAULT dflt_case,      -- Падеж должности
    regime_post       IN     VARCHAR2 DEFAULT dflt_post,      -- Режим вывода должности
    regime_init_dept  IN     VARCHAR2 DEFAULT dflt_init_dept  -- Режим вывода первой буквы подразделения
  ) RETURN            VARCHAR2
  IS
    l_post            VARCHAR2(32767) := trim(post_name);
    l_suffix          VARCHAR2(32767) := trim(post_suffix);
    l_dept_long       VARCHAR2(32767) := trim(dept_long_name);
    l_dept            VARCHAR2(32767);
    
    --
    l_no_dept         BOOLEAN := lower(l_post) = lower(l_dept_long)
                                 OR l_dept_long IS NOT NULL AND (
                                      instr(lower(l_post), ' '||lower(l_dept_long))> 0
                                      OR instr(lower(l_post), lower(l_dept_long)||' ') > 0
                                    )
                                 -- pai Костыль, если в должности указана довернность, то выводим ее всегда как есть   
                                 OR l_post like '%доверенности%'
                                 OR l_post like '%АО' || chr(160) || '"Связьтранснефть"%';
    --
    PROCEDURE replace_duplicate (text IN VARCHAR2)
    IS
      l_text VARCHAR2(4000) := ' '||trim(text);
    BEGIN
      IF l_text != ' ' THEN
        IF instr(l_post, l_text) > 0 THEN
          l_post := REPLACE(post_name, l_text);
        END IF;
      END IF;
    END;
    --
    FUNCTION add_text (
      text1 IN VARCHAR2,
      text2 IN VARCHAR2
    ) RETURN VARCHAR2
    IS
    BEGIN
      RETURN text1||CASE WHEN text1 IS NOT NULL AND text2 IS NOT NULL THEN ' ' END||text2;
    END;
    
  BEGIN
    check_regime_post(regime_post);
    check_phrase_case(phrase_case);
    IF l_post IS NULL OR regime_post = c_post_as_is AND phrase_case = c_nominative THEN
      RETURN post_name;
    END IF;
    IF regime_post IN (
         c_post_possible,
         c_post,
         c_post_dept,
         c_post_long_dept
       )
    THEN
      IF cutted_post(post_name) and Not l_no_dept THEN
        IF l_dept_long IS NULL AND regime_post != c_post_possible THEN
          RAISE_APPLICATION_ERROR(ec_no_dept, 'Для сокращения наименования должности не хватает полного наименования подразделения!');
        ELSIF l_dept_long IS NOT NULL THEN
          cut_post (
            post_name => l_post,
            dept_long_name => l_dept_long
          );
        END IF;
      END IF;
    END IF;
    replace_duplicate(dept_name);
    IF regime_post IN (
         c_post_possible,
         c_post_dept
       )
    THEN
      l_dept := trim(dept_name);
      IF l_dept IS NULL AND regime_post = c_post_dept THEN
        RAISE_APPLICATION_ERROR(ec_no_dept, 'Для выбранного режима отображения должности не хватает краткого наименования подразделения!');
      END IF;
      l_dept := dept (
                  dept_name => NVL (
                                 dept_name,
                                 dept_init (
                                   dept_name => l_dept_long,
                                   regime_init => regime_init_dept                                 
                                 )
                               ),
                  phrase_case => c_genitive
                );
    END IF;
    IF regime_post IN (
         c_post_possible,
         c_post_long_dept
       ) AND l_dept IS NULL
    THEN
      IF l_dept_long IS NULL THEN
        IF regime_post = c_post_long_dept THEN
          RAISE_APPLICATION_ERROR(ec_no_dept, 'Для выбранного режима отображения должности не хватает полного наименования подразделения!');
        END IF;
      ELSE
        l_dept := dept (
                    dept_name => dept_init (
                                   dept_name => l_dept_long,
                                   regime_init => regime_init_dept                                 
                                 ),
                    phrase_case => c_genitive
                  );
      END IF;
    END IF;
    IF phrase_case != c_nominative THEN
      l_post := post_stub (
        post_name => l_post,
        phrase_case => phrase_case
      );
    END IF;
    l_post := add_text(l_post, l_suffix);
    IF l_no_dept THEN
      RETURN REPLACE(l_post, '  ', ' ');
    ELSE
      RETURN REPLACE(add_text(l_post, l_dept), '  ', ' ');
    END IF;
  END;
  --
  FUNCTION print_date (
  -- Печать даты
    p_date          IN     DATE DEFAULT NULL,                 -- Дата
    regime          IN     VARCHAR2 DEFAULT dflt_date,        -- Режим вывода даты
    regime_day      IN     VARCHAR2 DEFAULT dflt_day          -- Режим вывода дня месяца
  ) RETURN          VARCHAR2
  IS
    --
    FUNCTION print_day
    RETURN         VARCHAR2
    IS
    BEGIN
      IF regime_day = c_day_short THEN
        RETURN LTRIM(to_char(p_date, 'dd'), '0');
      ELSIF regime_day = c_day_long THEN
        RETURN to_char(p_date, 'dd');
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода дня месяца!');
      END IF;
      RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода дня месяца!');
    END;
    --
    FUNCTION print_month
    RETURN       VARCHAR2
    IS
    BEGIN
      RETURN rtrim (
               replace (
                 replace (
                   replace (
                     replace (
                       to_char (
                         p_date,
                         'month',
                         'NLS_DATE_LANGUAGE = RUSSIAN'
                       ),
                       'ь',
                       'я'
                     ),
                     'т',
                     'та'
                   ),
                   'й',
                   'я'
                 ),
                 'тая',
                 'тя'
               ),
               ' '
             )
      ;
    END;
    --
    FUNCTION print_year RETURN VARCHAR2 IS
    BEGIN
      IF regime IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Не задан режим вывода даты!');
      END IF;
      CASE regime
        WHEN c_add_short_year THEN
          RETURN to_char(p_date, 'yyyy')||' г.';
        WHEN c_add_long_year THEN
          RETURN to_char(p_date, 'yyyy')||' года';
        ELSE
          RAISE_APPLICATION_ERROR(-20001, 'Задан неизвестный режим вывода даты!');
      END CASE;
    END;
    --
  BEGIN
    IF p_date IS NULL THEN
      RETURN '"____"___________20___'||print_year;
    END IF;
    RETURN print_day||' '||print_month||' '||print_year;
  END;
  --
  --
  FUNCTION print_count (
  -- Печать количества
    p_cnt           IN     NUMBER,                            -- Количество
    sex             IN     VARCHAR2                           -- Пол единицы измерения
  ) RETURN          VARCHAR2
  IS
    max_val_print   CONSTANT  NUMBER := 100000000000;
    retval          VARCHAR2(300);
  BEGIN
    IF p_cnt > 100000000000 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Функция может преобразовать в строку количество до '||to_char(max_val_print)||' включительно!');
    END IF;
    IF MOD(p_cnt, 1) != 0 THEN
       -- TODO реализовать вывод дробного количества в текстовом режиме
       RAISE_APPLICATION_ERROR(-20001, 'Вывод дробного количества в текстовом режиме не реализован!');
    END IF;
    IF sex IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан пол единицы измерения!');
    END IF;
    IF sex NOT IN (c_male, c_female, c_neuter) THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверно задан пол единицы измерения!');
    END IF;
    --
    IF p_cnt = 0 THEN
      RETURN 'ноль';
    END IF;
    --
    retval := ltrim (
      to_char (
        p_cnt,
        '9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.'
      )
    );
    --
    retval := replace(retval, '.', 'r');
    -- t - тысячи; m - милионы; M - миллиарды;
    retval := replace(retval, ',,,,,,', 'eM');
    retval := replace(retval, ',,,,,', 'em');
    retval := replace(retval, ',,,,', 'et');
    -- e - единицы; d - десятки; c - сотни;
    retval := replace(retval, ',,,', 'e');
    retval := replace(retval, ',,', 'd');
    retval := replace(retval, ',', 'c');
    --
    retval := replace(retval, '0c0d0et', '');
    retval := replace(retval, '0c0d0em', '');
    retval := replace(retval, '0c0d0eM', '');
    retval := replace(retval, '0c', '');
    retval := replace(retval, '1c', 'сто ');
    retval := replace(retval, '2c', 'двести ');
    retval := replace(retval, '3c', 'триста ');
    retval := replace(retval, '4c', 'четыреста ');
    retval := replace(retval, '5c', 'пятьсот ');
    retval := replace(retval, '6c', 'шестьсот ');
    retval := replace(retval, '7c', 'семьсот ');
    retval := replace(retval, '8c', 'восемьсот ');
    retval := replace(retval, '9c', 'девятьсот ');
    --
    retval := replace(retval, '1d0e', 'десять ');
    retval := replace(retval, '1d1e', 'одиннадцать ');
    retval := replace(retval, '1d2e', 'двенадцать ');
    retval := replace(retval, '1d3e', 'тринадцать ');
    retval := replace(retval, '1d4e', 'четырнадцать ');
    retval := replace(retval, '1d5e', 'пятнадцать ');
    retval := replace(retval, '1d6e', 'шестнадцать ');
    retval := replace(retval, '1d7e', 'семнадцать ');
    retval := replace(retval, '1d8e', 'восемнадцать ');
    retval := replace(retval, '1d9e', 'девятнадцать ');
    --
    retval := replace(retval, '0d', '');
    retval := replace(retval, '2d', 'двадцать ');
    retval := replace(retval, '3d', 'тридцать ');
    retval := replace(retval, '4d', 'сорок ');
    retval := replace(retval, '5d', 'пятьдесят ');
    retval := replace(retval, '6d', 'шестьдесят ');
    retval := replace(retval, '7d', 'семьдесят ');
    retval := replace(retval, '8d', 'восемьдесят ');
    retval := replace(retval, '9d', 'девяносто ');
    --
    retval := replace(retval, '1et', 'одна тысяча ');
    retval := replace(retval, '2et', 'две тысячи ');
    retval := replace(retval, '3et', 'три тысячи ');
    retval := replace(retval, '4et', 'четыре тысячи ');
    retval := replace(retval, '1em', 'один миллион ');
    retval := replace(retval, '2em', 'два миллиона ');
    retval := replace(retval, '3em', 'три миллиона ');
    retval := replace(retval, '4em', 'четыре миллиона ');
    retval := replace(retval, '1eM', 'один миллиард ');
    retval := replace(retval, '2eM', 'два миллиарда ');
    retval := replace(retval, '3eM', 'три миллиарда ');
    retval := replace(retval, '4eM', 'четыре миллиарда ');
    --
    retval := replace(retval, '0et', 't');
    retval := replace(retval, '0em', 'm');
    retval := replace(retval, '0eM', 'M');
    retval := replace(retval, '0er', 'r');
    --
    CASE sex
      WHEN c_male THEN
        retval := replace(retval, '1er', 'один');
        retval := replace(retval, '2er', 'два');
      WHEN c_female THEN
        retval := replace(retval, '1er', 'одна');
        retval := replace(retval, '2er', 'две');
      WHEN c_neuter THEN
        retval := replace(retval, '1er', 'одно');
        retval := replace(retval, '2er', 'два');
    END CASE;
    --
    retval := replace(retval, '3er', 'три');
    retval := replace(retval, '4er', 'четыре');
    --
    retval := replace(retval, '1e', 'один ');
    retval := replace(retval, '2e', 'два ');
    retval := replace(retval, '3e', 'три ');
    retval := replace(retval, '4e', 'четыре ');
    retval := replace(retval, '5e', 'пять ');
    retval := replace(retval, '6e', 'шесть ');
    retval := replace(retval, '7e', 'семь ');
    retval := replace(retval, '8e', 'восемь ');
    retval := replace(retval, '9e', 'девять ');
    --
    retval := replace(retval, 't', 'тысяч ');
    retval := replace(retval, 'm', 'миллионов ');
    retval := replace(retval, 'M', 'миллиардов ');
    retval := replace(retval, 'r',  NULL);
    --
    RETURN trim(retval);
  END;
  --
  FUNCTION print_count (
  -- Печать количества
    p_cnt           IN     NUMBER,                            -- Количество
    pttrn_one       IN     VARCHAR2,                          -- Шаблон количества, заканчивающегося на 1, исключая 11 (пр. '%s файл' - именительный падеж, ед.ч.)
    pttrn_two       IN     VARCHAR2,                          -- Шаблон количества, заканчивающегося на 2..4, исключая 12..14 (пр. '%s файла' - родительный падеж, ед.ч)
    pttrn_five      IN     VARCHAR2,                          -- Шаблон количества, заканчивающегося на 0, 5..9, 11..14, (пр. '%s файлов' - родительный падеж, мн.ч.)
    pttrn_null      IN     VARCHAR2 := NULL,                  -- Шаблон неопределенного количества (пр. 'ошибка получения') - если содержит %s в этом месте будет 0
    pttrn_only_zero IN     VARCHAR2 := NULL,                  -- Шаблон для нулевого количества (пр. '%s файлов' - именительный падеж, ед.ч.) - если не заполнить, будет выведена пустая строка
    pttrn_only_one  IN     VARCHAR2 := NULL,                  -- Шаблон единичного количества (пр. '%s файл' - именительный падеж, ед.ч.) - если не заполнить, будет pttrn_one 
    sex             IN     NUMBER   := NULL,                  -- Пол единицы измерения: если указан, будет вывод числа в текстовом виде
    regime_init     IN     VARCHAR2 := NULL                   -- Режим вывода первой буквы
  ) RETURN          VARCHAR2
  IS
    l_decade        CHAR(1);
    l_unit          CHAR(1);
    l_cnt           VARCHAR2(32767);
    retval          VARCHAR(32767);
  BEGIN
    IF pttrn_one IS NULL OR instr(pttrn_one, c_pttrn_count) = -1
       OR pttrn_two IS NULL OR instr(pttrn_two, c_pttrn_count) = -1
       OR pttrn_five IS NULL OR instr(pttrn_five, c_pttrn_count) = -1
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'В шаблоне не указан паттерн количества '''||c_pttrn_count||'''!');
    END IF;
    IF p_cnt IS NULL THEN
      IF sex IS NULL THEN
        l_cnt := 0;
      ELSE
        l_cnt := print_count (
          p_cnt => 0,
          sex => sex
        );
      END IF;
      retval := REPLACE(pttrn_null, c_pttrn_count, l_cnt);
    ELSE
      IF sex IS NULL THEN
        l_cnt := p_cnt;
      ELSE
        l_cnt := print_count (
          p_cnt => p_cnt,
          sex => sex
        );
      END IF;
      IF p_cnt = 0 THEN
        retval := REPLACE(pttrn_only_zero, c_pttrn_count, l_cnt);
      ELSE
        IF p_cnt = 1 THEN
          retval := REPLACE(NVL(pttrn_only_one, pttrn_one), c_pttrn_count, l_cnt);
        ELSIF MOD(p_cnt, 1) = 0 THEN
          l_decade := SUBSTR((to_char(MOD(p_cnt, 100), '00')), 2, 1);
          l_unit := SUBSTR((to_char(MOD(p_cnt, 100), '00')), 3, 1);
          IF l_decade = '1' OR l_unit IN (0, 5, 6, 7, 8, 9) THEN
            retval := REPLACE(pttrn_five, c_pttrn_count, l_cnt);
          ELSIF l_unit = '1' THEN
            retval := REPLACE(pttrn_one, c_pttrn_count, l_cnt);
          ELSE
            retval := REPLACE(pttrn_two, c_pttrn_count, l_cnt);
          END IF;
        ELSE
          IF sex IS NULL THEN
            RETURN REPLACE(pttrn_two, c_pttrn_count, trim(rtrim(to_char(p_cnt, '0D9999999999999999'), 0)));
          ELSE
            RETURN REPLACE(pttrn_two, c_pttrn_count, l_cnt);
          END IF;
        END IF;
      END IF;
    END IF;
    CASE
      WHEN NVL(regime_init, c_init_as_is) = c_init_as_is THEN
        RETURN retval;
      WHEN regime_init = c_init_lower THEN
        RETURN init_lower(retval);
      WHEN regime_init = c_init_upper THEN
        RETURN init_upper(retval);
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Неверно задан режим вывода первой буквы числа!');
    END CASE;
  END;
  --
  FUNCTION print_sum (
  -- Печать денежной суммы
    p_sum           IN     NUMBER DEFAULT NULL,                           -- Сумма
    currency_code   IN     curency.charcode%TYPE DEFAULT dflt_curr_code,  -- Код валюты
    regime_init     IN     VARCHAR2 := c_init_upper                       -- Режим вывода первой буквы
  ) RETURN          VARCHAR2
  IS
    --  
    retval          VARCHAR(32767);
    r_currency      curency%ROWTYPE;
    --
    PROCEDURE get_currency IS
    BEGIN
      SELECT
        t.*
      INTO
        r_currency
      FROM
        curency t
      WHERE
        t.charcode = currency_code;
      --
    EXCEPTION WHEN no_data_found THEN
      RAISE_APPLICATION_ERROR(-20001, 'Невозможно найти валюту по коду = '''||to_char(currency_code)||'''!');
    END;
    --
    PROCEDURE check_field (
      field_name  IN VARCHAR2,
      field_value IN VARCHAR2
    ) IS
    BEGIN
      IF trim(field_value) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Валюта: '''||r_currency.name||''': в справочнике не задана '||field_name||'!');
      END IF;
    END;
    --
    PROCEDURE check_currency IS
    BEGIN
      check_field (
        field_name => 'основная единица в именительном падеже',
        field_value => r_currency.base_nominative
      );
      check_field (
        field_name => 'основная единица в родительном падеже',
        field_value => r_currency.base_genitive
      );
      check_field (
        field_name => 'основная единица в родительном падеже во множественном числе',
        field_value => r_currency.base_genitive_plural
      );
      check_field (
        field_name => 'дробная единица в сокращенной форме',
        field_value => r_currency.penny_short
      );
    END;
    --
    FUNCTION penny
    RETURN VARCHAR2
    IS
    BEGIN
      RETURN CASE WHEN p_sum IS NULL THEN ' ___' ELSE to_char(floor(MOD(NVL(p_sum, 0), 1)*100), '09') END || ' ' || r_currency.penny_short;
    END;
    --
  BEGIN
    IF TRIM(currency_code) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Не задан код валюты!');
    END IF;
    get_currency;
    check_currency;
    retval := print_count (
                p_cnt => floor(p_sum),
                pttrn_one => c_pttrn_count || ' ' || r_currency.base_nominative,
                pttrn_two => c_pttrn_count || ' ' || r_currency.base_genitive,
                pttrn_five => c_pttrn_count || ' ' || r_currency.base_genitive_plural,
                pttrn_null => '__________________________________________________________________________________________________________ ______',
                sex => r_currency.base_sex,
                regime_init => regime_init
              );
    retval := retval
              || CASE
                   WHEN retval IS NULL THEN
                     TRIM(penny)
                   ELSE
                     penny
                 END
    ;
    RETURN retval;
  END;
END pk_wordforms;
/
