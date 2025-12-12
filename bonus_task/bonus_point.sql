--Bonus point task: Database schema
--Tables from file
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    tin VARCHAR(12) UNIQUE NOT NULL CHECK (LENGTH(tin) = 12),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    status VARCHAR(10) CHECK (status IN ('active', 'blocked', 'frozen')) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt NUMERIC(15, 2) DEFAULT 3000000.00
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
    account_number VARCHAR(34) UNIQUE NOT NULL,
    currency VARCHAR(3) CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance NUMERIC(15, 2) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY, from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    exchange_rate NUMERIC(10, 6) DEFAULT 1.0,
    amount_kzt NUMERIC(15, 2) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(20) CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description TEXT
);

CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate NUMERIC(10, 6) NOT NULL CHECK (rate > 0),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP
);

CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(10) CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) DEFAULT 'system',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50) DEFAULT '127.0.0.1'
);

--Populate each table with at least 10 meaningful records for testing. (Часть тестов сгенерировано ИИ для разных кейсов и минимизации однотипных действий)
INSERT INTO customers (tin, full_name, phone, email, status, daily_limit_kzt) VALUES
('123456789012', 'Ким Анатолий', '+77001111111', 'kim@example.com', 'active', 500000.00),
('123456789013', 'Ким Тимур', '+77022222222', 'timur@example.com', 'active', 1000000.00),
('123456789014', 'Лизько Владислав', '+77033333333', 'vlad@example.com', 'blocked', 0.00),
('123456789015', 'Даурен Ибрагим', '+77044444444', 'dauren@example.com', 'active', 2000000.00),
('123456789016', 'Ерлан Тлеухан', '+77055555555', 'erlan@example.com', 'active', 300000.00),
('123456789017', 'Ли Кирилл', '+77066666666', 'kirill@example.com', 'frozen', 10000.00),
('123456789018', 'Зере Зарина', '+77077777777', 'zere@example.com', 'active', 1500000.00),
('123456789019', 'Ильяс Иман', '+77088888888', 'ilyas@example.com', 'active', 800000.00),
('123456789020', 'Казбек Канат', '+77099999999', 'kazbek@example.com', 'active', 2500000.00),
('123456789021', 'Лейла Лаура', '+77100000000', 'leila@example.com', 'active', 500000.00);


INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(1, 'KZ123456789012345678', 'KZT', 150000.00, TRUE),
(1, 'KZ123456789012345679', 'USD', 5000.00, TRUE),
(2, 'KZ123456789012345680', 'KZT', 3000000.00, TRUE),
(3, 'KZ123456789012345681', 'KZT', 1000.00, TRUE),
(4, 'KZ123456789012345682', 'EUR', 2000.00, TRUE),
(5, 'KZ123456789012345683', 'RUB', 50000.00, TRUE),
(6, 'KZ123456789012345684', 'KZT', 50000.00, FALSE), 
(7, 'KZ123456789012345685', 'USD', 10000.00, TRUE),
(8, 'KZ123456789012345686', 'KZT', 750000.00, TRUE),
(9, 'KZ123456789012345687', 'KZT', 10000000.00, TRUE);

INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from) VALUES
('USD', 'KZT', 450.00, CURRENT_TIMESTAMP),
('EUR', 'KZT', 500.00, CURRENT_TIMESTAMP),
('RUB', 'KZT', 5.00, CURRENT_TIMESTAMP),
('KZT', 'USD', 1/450.00, CURRENT_TIMESTAMP),
('KZT', 'EUR', 1/500.00, CURRENT_TIMESTAMP),
('KZT', 'RUB', 1/5.00, CURRENT_TIMESTAMP),
('USD', 'EUR', 0.90, CURRENT_TIMESTAMP),
('EUR', 'USD', 1.11, CURRENT_TIMESTAMP);

INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, completed_at, description) VALUES
(1, 3, 50000.00, 'KZT', 1.0, 50000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Перевод другу'),
(NULL, 2, 1000.00, 'USD', 450.00, 450000.00, 'deposit', 'completed', CURRENT_TIMESTAMP, 'Пополнение счета USD'),
(3, NULL, 20000.00, 'KZT', 1.0, 20000.00, 'withdrawal', 'completed', CURRENT_TIMESTAMP, 'Снятие наличных'),
(4, 5, 500.00, 'KZT', 0.002, 500.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Перевод в EUR'),
(2, 8, 100.00, 'USD', 450.00, 45000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Международный перевод'),
(9, 11, 100000.00, 'KZT', 1.0, 100000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Крупный перевод'),
(10, 1, 500000.00, 'KZT', 1.0, 500000.00, 'transfer', 'failed', CURRENT_TIMESTAMP, 'Неудачная попытка'),
(5, 7, 1000.00, 'EUR', 500.00, 500000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Перевод в RUB'),
(8, 4, 5000.00, 'USD', 450.00, 2250000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Бизнес-платеж'),
(11, 9, 10000.00, 'KZT', 1.0, 10000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Обратный перевод');


--Tasks
--Task 1: Transaction Management
CREATE OR REPLACE PROCEDURE process_transfer(
    from_account_number VARCHAR(34),  -- Номер счета откуда списываем
    to_account_number VARCHAR(34),    -- Номер счета куда зачисляем  
    amount NUMERIC(15, 2),            -- Сколько денег переводим
    currency VARCHAR(3),              -- В какой валюте перевод
    description TEXT DEFAULT 'Перевод' -- Что пишем в описании
)
LANGUAGE plpgsql
AS $$
DECLARE
    fromacc RECORD;    
    toacc RECORD;      
    rate NUMERIC(10, 6); -- Курс обмена, используем для конвертации
    sumkzt NUMERIC(15, 2); -- Сумма в тенге для проверки лимита
    used NUMERIC(15, 2);   
    transid INTEGER;       
BEGIN
    -- ШАГ 1: Стоп оба счета, чтобы никто не мог их изменить пока мы работаем
    SELECT a.*, c.status, c.daily_limit_kzt
    INTO fromacc
    FROM accounts a
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.account_number = from_account_number
      AND a.is_active = TRUE
    FOR UPDATE; 

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ошибка: Счет отправителя не найден или закрыт';
    END IF;
    
    --блокируем счет получателя
    SELECT a.*
    INTO toacc
    FROM accounts a
    WHERE a.account_number = to_account_number
      AND a.is_active = TRUE
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'ошибка: Счет получателя не найден или закрыт';
    END IF;
    
    -- ШАГ 2: Проверяем можно ли вообще делать перевод (Клиент активен или нет)
    IF fromacc.status != 'active' THEN
        RAISE EXCEPTION 'CUST001: Клиент заблокирован или заморожен';
    END IF;
    
    -- На счету должно хватать денег
    IF fromacc.balance < amount THEN
        RAISE EXCEPTION 'BAL001: Недостаточно средств. Есть: %, Нужно: %', 
                        fromacc.balance, amount;
    END IF;
    
    -- ШАГ 3: Проверяем дневной лимит ( в тенге)
    IF currency = 'KZT' THEN
        sumkzt := amount; 
    ELSE
        -- Ищем актуальный курс валюты к тенге
        SELECT rate INTO rate
        FROM exchange_rates
        WHERE from_currency = currency
          AND to_currency = 'KZT'
          AND CURRENT_TIMESTAMP BETWEEN valid_from AND COALESCE(valid_to, 'infinity')
        LIMIT 1;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'RATE001: Не знаем курс % к тенге', currency;
        END IF;
        
        sumkzt := amount * rate;  -- Конвертируем в тенге
    END IF;
    
    -- Считаем сколько клиент уже перевел сегодня
    SELECT COALESCE(SUM(amount_kzt), 0) INTO used
    FROM transactions
    WHERE from_account_id = fromacc.account_id
      AND status = 'completed'
      AND DATE(created_at) = CURRENT_DATE;
    
    -- Проверяем не превысит ли перевод лимит
    IF used + sumkzt > fromacc.daily_limit_kzt THEN
        RAISE EXCEPTION 'LIMIT001: Лимит % тенге. Уже потрачено: %, Перевод: %', 
                        fromacc.daily_limit_kzt, used, sumkzt;
    END IF;
    
    -- ШАГ 4: Конвертируем между валютами 
    rate := 1.0;  -- По умолчанию курс 1 (одинаковые валюты)
    IF fromacc.currency != toacc.currency THEN
        SELECT rate INTO rate
        FROM exchange_rates
        WHERE from_currency = fromacc.currency
          AND to_currency = toacc.currency
          AND CURRENT_TIMESTAMP BETWEEN valid_from AND COALESCE(valid_to, 'infinity')
        LIMIT 1;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'RATE002: Не знаем как конвертировать % в %', 
                            fromacc.currency, toacc.currency;
        END IF;
    END IF;
    
    -- ШАГ 5: Все проверки прошли, делаем перевод
    INSERT INTO transactions (
        from_account_id, to_account_id,
        amount, currency, exchange_rate, amount_kzt,
        type, status, description, created_at, completed_at
    ) VALUES (
        fromacc.account_id, toacc.account_id,
        amount, currency, rate, sumkzt,
        'transfer', 'completed', description, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING transaction_id INTO transid;
    
    -- ШАГ 6: Меняем балансы на счетах
    UPDATE accounts SET balance = balance - amount WHERE account_id = fromacc.account_id;
    -- Зачисление получателю (с конвертацией если нужно)
    UPDATE accounts SET balance = balance + (amount * rate) WHERE account_id = toacc.account_id;
    
    -- ШАГ 7: Логируем успешную операцию
    INSERT INTO audit_log (table_name, record_id, action, new_values)
    VALUES ('transactions', transid, 'INSERT',
            jsonb_build_object('amount', amount, 'status', 'completed', 'note', description));
    
    RAISE NOTICE 'Перевод выполнен!', 
                 transid, amount, currency, (amount * rate), toacc.currency;
    
EXCEPTION WHEN OTHERS THEN
    -- ШАГ 8: На всякий сейф-бэк
    INSERT INTO audit_log (table_name, record_id, action, new_values)
    VALUES ('transfer_failed', 0, 'FAILED',
            jsonb_build_object(
                'from', from_account_number,
                'to', to_account_number,
                'amount', amount,
                'error', SQLERRM
            ));
    
    -- Передаем ошибку дальше
    RAISE EXCEPTION 'Ошибка перевода: %', SQLERRM;
END;
$$;

-- Тест 1: Успешный перевод в тенге (KZT → KZT)
CALL process_transfer(
    'KZ123456789012345678',  -- Счет отправителя (KZT)
    'KZ123456789012345680',  -- Счет получателя (KZT)
    5000.00,                 
    'KZT',                   
    'Тестовый перевод между тенговыми счетами'
);

-- Тест 2: Ошибка - недостаточно средств
CALL process_transfer(
    'KZ123456789012345678',  -- Счет отправителя
    'KZ123456789012345680',  -- Счет получателя
    9999999.00,              -- Слишком большая сумма
    'KZT',
    'Проверка недостатка средств'
);

--Task 2. Views for Reporting
-- View 1: Сводка по клиентам и балансам
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH currentrates AS (
    -- Берем последние актуальные курсы к тенге
    SELECT DISTINCT ON (from_currency) 
           from_currency, 
           rate AS tokzt
    FROM exchange_rates
    WHERE to_currency = 'KZT' 
      AND CURRENT_TIMESTAMP BETWEEN valid_from AND COALESCE(valid_to, 'infinity')
    ORDER BY from_currency, valid_from DESC
)
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(a.account_id) AS accountcount,
    SUM(a.balance) AS balanceall,
    SUM(a.balance * COALESCE(r.tokzt, 1)) AS balancekzt,
    c.daily_limit_kzt,
    COALESCE((
        SELECT SUM(t.amount_kzt)
        FROM accounts a2
        JOIN transactions t ON a2.account_id = t.from_account_id
        WHERE a2.customer_id = c.customer_id
          AND t.status = 'completed'
          AND t.type = 'transfer'
          AND DATE(t.created_at) = CURRENT_DATE
    ), 0) AS todayspent,
    ROUND(
        COALESCE((
            SELECT SUM(t.amount_kzt)
            FROM accounts a2
            JOIN transactions t ON a2.account_id = t.from_account_id
            WHERE a2.customer_id = c.customer_id
              AND t.status = 'completed'
              AND t.type = 'transfer'
              AND DATE(t.created_at) = CURRENT_DATE
        ), 0) * 100.0 / NULLIF(c.daily_limit_kzt, 0), 
        2
    ) AS limitpercent,
    RANK() OVER (ORDER BY SUM(a.balance * COALESCE(r.tokzt, 1)) DESC) AS richrank
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id AND a.is_active = TRUE
LEFT JOIN currentrates r ON a.currency = r.from_currency
GROUP BY c.customer_id, c.full_name, c.daily_limit_kzt
ORDER BY balancekzt DESC;

-- View 2: Ежедневный отчет по транзакциям
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH daily AS (
    SELECT 
        DATE(created_at) AS day,
        type,
        currency,
        COUNT(*) AS count,
        SUM(amount) AS total,
        SUM(amount_kzt) AS totalkzt,
        AVG(amount_kzt) AS avgkzt
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE(created_at), type, currency
)
SELECT 
    day,
    type,
    currency,
    count,
    total,
    totalkzt,
    avgkzt,
    SUM(totalkzt) OVER (PARTITION BY type, currency ORDER BY day) AS runtotal,
    LAG(totalkzt) OVER (PARTITION BY type, currency ORDER BY day) AS prevday,
    CASE 
        WHEN LAG(totalkzt) OVER (PARTITION BY type, currency ORDER BY day) = 0 THEN NULL
        ELSE ROUND((totalkzt - LAG(totalkzt) OVER (PARTITION BY type, currency ORDER BY day)) * 100.0 
                   / LAG(totalkzt) OVER (PARTITION BY type, currency ORDER BY day), 2)
    END AS growth
FROM daily
ORDER BY day DESC, type;

-- View 3: Подозрительная активность (с защитой Security Barrier)
CREATE OR REPLACE VIEW suspicious_activity_view 
WITH (security_barrier = true) AS
SELECT 
    'bigtransfer' AS flag,
    t.transaction_id,
    t.from_account_id,
    t.amount_kzt,
    t.created_at,
    'Перевод больше 5 млн' AS reason
FROM transactions t
WHERE t.status = 'completed'
  AND t.type = 'transfer'
  AND t.amount_kzt > 5000000

UNION ALL

SELECT 
    'manytransfers' AS flag,
    NULL AS transaction_id,
    a.account_id AS from_account_id,
    NULL AS amount_kzt,
    MAX(t.created_at) AS created_at,
    'Больше 10 переводов за час' AS reason
FROM transactions t
JOIN accounts a ON t.from_account_id = a.account_id
WHERE t.status = 'completed'
  AND t.type = 'transfer'
GROUP BY a.account_id, DATE_TRUNC('hour', t.created_at)
HAVING COUNT(*) > 10

UNION ALL

SELECT 
    'fasttransfer' AS flag,
    t2.transaction_id,
    t2.from_account_id,
    t2.amount_kzt,
    t2.created_at,
    'Быстрый перевод через ' || EXTRACT(SECOND FROM (t2.created_at - t1.created_at)) || ' сек' AS reason
FROM transactions t1
JOIN transactions t2 ON t1.from_account_id = t2.from_account_id
WHERE t1.status = 'completed'
  AND t2.status = 'completed' AND t1.type = 'transfer'  AND t2.type = 'transfer' AND t2.created_at > t1.created_at AND t2.created_at <= t1.created_at + INTERVAL '60 seconds'
  AND NOT EXISTS (
    SELECT 1 
    FROM transactions t3 
    WHERE t3.from_account_id = t1.from_account_id
      AND t3.created_at > t1.created_at
      AND t3.created_at < t2.created_at
      AND t3.status = 'completed'
      AND t3.type = 'transfer'
  );

-- тест кейсы
--View 1
SELECT * FROM customer_balance_summary LIMIT 5;

--View 2  
SELECT * FROM daily_transaction_report WHERE day >= CURRENT_DATE - 7;

--View 3
SELECT * FROM suspicious_activity_view; 

--Task 3. Performance Optimization with Indexes
-- 1. B-tree 
CREATE INDEX idx_trans_limit_check ON transactions 
    (from_account_id, created_at) 
    INCLUDE (amount_kzt)
    WHERE status = 'completed' AND type = 'transfer';

-- 2. Partial index
CREATE INDEX idx_active_accounts ON accounts (account_number) 
    WHERE is_active = TRUE;

-- 3. Composite Index
CREATE INDEX idx_email_ci ON customers (LOWER(email));


-- 4. GIN индекс 
CREATE INDEX idx_audit_json ON audit_log USING GIN (new_values);

-- 5. Hash Index
CREATE INDEX idx_account_hash ON accounts USING HASH (account_number);


-- Тест 1: Проверка дневного лимита 
EXPLAIN ANALYZE
SELECT COALESCE(SUM(amount_kzt), 0)
FROM transactions
WHERE from_account_id = 1
  AND status = 'completed'
  AND type = 'transfer'
  AND DATE(created_at) = CURRENT_DATE;

-- Тест 2: Поиск активного счета 
EXPLAIN ANALYZE
SELECT account_id, balance, currency
FROM accounts
WHERE account_number = 'KZ123456789012345678'
  AND is_active = TRUE;

-- Тест 3: Поиск по email 
EXPLAIN ANALYZE
SELECT customer_id, full_name
FROM customers
WHERE LOWER(email) = 'kim@example.com';

-- Тест 4: Поиск в JSONB логах 
EXPLAIN ANALYZE
SELECT log_id, action, changed_at
FROM audit_log
WHERE new_values @> '{"status": "completed"}'
LIMIT 5;

-- Тест 5: Поиск счета по номеру 
EXPLAIN ANALYZE
SELECT *
FROM accounts
WHERE account_number = 'KZ123456789012345680';

-- Тест 6: Проверка конкурентности 
EXPLAIN ANALYZE
SELECT a.*, c.status
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.account_number = 'KZ123456789012345678'
  AND a.is_active = TRUE
FOR UPDATE;


-- Task 4: Advanced Procedure - Batch Processing
CREATE PROCEDURE process_salary_batch(
    company_account_number VARCHAR(34),
    payments_json JSONB,
    description TEXT DEFAULT 'Salary payments'
)
LANGUAGE plpgsql
AS $$
DECLARE
    company RECORD;
    total_amount NUMERIC(15, 2);
    success_count INT := 0;
    fail_count INT := 0;
    fail_details JSONB := '[]'::JSONB;
    lock_id BIGINT;
    
    -- Для итерации
    payment RECORD;
    target_account RECORD;
    exchange_rate NUMERIC(10, 6);
    transaction_id INT;
    amount_kzt NUMERIC(15, 2);
BEGIN
    -- 1. Проверка входных данных
    IF payments_json IS NULL OR jsonb_array_length(payments_json) = 0 THEN
        RAISE EXCEPTION 'ошибка: Empty payments list';
    END IF;
    
    -- 2. Считаем общую сумму
    SELECT COALESCE(SUM((elem->>'amount')::NUMERIC), 0)
    INTO total_amount
    FROM jsonb_array_elements(payments_json) AS elem;
    
    IF total_amount <= 0 THEN
        RAISE EXCEPTION 'ошибка: Invalid total amount: %', total_amount;
    END IF;
    
    -- 3. Консультативная блокировка для компании
    lock_id := ('x' || substr(md5(company_account_number), 1, 16))::bit(64)::bigint;
    
    IF NOT pg_try_advisory_xact_lock(lock_id) THEN
        RAISE EXCEPTION 'ошибка: Another batch is processing for this company';
    END IF;
    
    -- 4. Получаем данные компании с блокировкой
    SELECT a.*, c.customer_id
    INTO company
    FROM accounts a
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.account_number = company_account_number
      AND a.is_active = TRUE
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'ошибка: Company account not found or inactive';
    END IF;
    
    -- 5. Проверяем баланс компании
    IF company.balance < total_amount THEN
        RAISE EXCEPTION 'ошибка: Insufficient balance. Available: %, Required: %',
                        company.balance, total_amount;
    END IF;
    
    -- 6. Основной цикл обработки платежей
    FOR payment IN 
        SELECT 
            row_number() OVER () as idx,
            elem->>'iin' as iin,
            (elem->>'amount')::NUMERIC as amount,
            COALESCE(elem->>'description', 'Salary payment') as note
        FROM jsonb_array_elements(payments_json) AS elem
    LOOP
        BEGIN
            -- Поиск счета сотрудника
            SELECT a.*
            INTO target_account
            FROM accounts a
            JOIN customers c ON a.customer_id = c.customer_id
            WHERE c.tin = payment.iin
              AND a.is_active = TRUE
              AND a.currency = company.currency  -- Только счета в той же валюте
            LIMIT 1;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'ошибка: Employee account not found for IIN: %', payment.iin;
            END IF;
            
            -- Получаем курс для конвертации в KZT 
            exchange_rate := 1.0;
            IF company.currency != 'KZT' THEN
                SELECT rate INTO exchange_rate
                FROM exchange_rates
                WHERE from_currency = company.currency
                  AND to_currency = 'KZT'
                  AND CURRENT_TIMESTAMP BETWEEN valid_from AND COALESCE(valid_to, 'infinity')
                ORDER BY valid_from DESC
                LIMIT 1;
                
                IF NOT FOUND THEN
                    RAISE EXCEPTION 'ошибка: Exchange rate not found for %', company.currency;
                END IF;
            END IF;
            
            amount_kzt := payment.amount * exchange_rate;
            
            -- Создаем транзакцию 
            INSERT INTO transactions (
                from_account_id, to_account_id,
                amount, currency, exchange_rate, amount_kzt,
                type, status, description, created_at
            ) VALUES (
                company.account_id, target_account.account_id,
                payment.amount, company.currency, 1.0, amount_kzt,
                'transfer', 'pending', payment.note, CURRENT_TIMESTAMP
            ) RETURNING transaction_id INTO transaction_id;
            
            -- Обновляем баланс получателя сразу
            UPDATE accounts 
            SET balance = balance + payment.amount
            WHERE account_id = target_account.account_id;
            
            success_count := success_count + 1;
            
        EXCEPTION WHEN OTHERS THEN
            -- Запоминаем ошибку
            fail_details := jsonb_insert(
                fail_details, 
                '{0}', 
                jsonb_build_object(
                    'iin', payment.iin,
                    'amount', payment.amount,
                    'error', SQLERRM
                ),
                true
            );
            
            fail_count := fail_count + 1;
        END;
    END LOOP;
    
    -- 7. Обновляем баланс компании 
    IF success_count > 0 THEN
        UPDATE accounts 
        SET balance = balance - total_amount
        WHERE account_id = company.account_id;
        
        -- Меняем статусы успешных транзакций
        UPDATE transactions
        SET status = 'completed',
            completed_at = CURRENT_TIMESTAMP
        WHERE from_account_id = company.account_id
          AND status = 'pending'
          AND DATE(created_at) = CURRENT_DATE;
    END IF;
    
    -- 8. Логируем результат
    INSERT INTO audit_log (table_name, record_id, action, new_values)
    VALUES ('salary_batch', 0, 'INSERT',
            jsonb_build_object(
                'company_account', company_account_number,
                'total_amount', total_amount,
                'success_count', success_count,
                'fail_count', fail_count,
                'description', description
            ));
    
    -- 9. Возвращаем результат через NOTICE
    RAISE NOTICE 'Batch processed: Success: %, Failed: %, Total: %',
                 success_count, fail_count, total_amount;
    
    -- 10. Если все платежи неудачные
    IF success_count = 0 THEN
        RAISE EXCEPTION 'ошибка: All payments failed. Details: %', fail_details;
    END IF;
    
END;
$$;

-- Materialized View для отчетности по зарплатным пакетам
CREATE MATERIALIZED VIEW IF NOT EXISTS salary_batch_report AS
WITH batch_data AS (
    SELECT 
        al.changed_at::date AS batch_date,
        al.new_values->>'company_account' AS company_account,
        (al.new_values->>'total_amount')::NUMERIC AS total_amount,
        (al.new_values->>'success_count')::INT AS success_count,
        (al.new_values->>'fail_count')::INT AS fail_count,
        al.new_values->>'description' AS description
    FROM audit_log al
    WHERE al.table_name = 'salary_batch'
      AND al.action = 'INSERT'
)
SELECT 
    batch_date,
    company_account,
    total_amount,
    success_count,
    fail_count,
    description,
    ROUND(success_count * 100.0 / NULLIF(success_count + fail_count, 0), 2) AS success_rate
FROM batch_data
ORDER BY batch_date DESC;

-- Индекс для быстрого обновления materialized view
CREATE INDEX idx_salary_batch_date ON salary_batch_report (batch_date DESC);

-- Тестовые вызовы
INSERT INTO customers (tin, full_name, phone, email, status) VALUES
('987654321098', 'TechCorp LLC', '+77110000000', 'tech@example.com', 'active'),
('987654321099', 'Иван Иванов', '+77110000001', 'ivan@example.com', 'active'),
('987654321100', 'Мария Петрова', '+77110000002', 'maria@example.com', 'active'),
('987654321101', 'Алексей Сидоров', '+77110000003', 'alex@example.com', 'active');

INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(11, 'KZ987654321098765432', 'KZT', 5000000.00, TRUE), 
(12, 'KZ987654321098765433', 'KZT', 10000.00, TRUE),    
(13, 'KZ987654321098765434', 'KZT', 10000.00, TRUE),    
(14, 'KZ987654321098765435', 'KZT', 10000.00, TRUE);    

-- Тест 1: Успешная пакетная обработка
CALL process_salary_batch(
    'KZ987654321098765432',
    '[
        {"iin": "987654321099", "amount": 500000.00, "description": "Salary Jan"},
        {"iin": "987654321100", "amount": 450000.00, "description": "Salary Jan"},
        {"iin": "987654321101", "amount": 400000.00, "description": "Salary Jan"}
    ]'::JSONB,
    'January salary batch'
);

-- Тест 2: С ошибкой (неверный IIN)
CALL process_salary_batch(
    'KZ987654321098765432',
    '[
        {"iin": "987654321099", "amount": 100000.00},
        {"iin": "999999999999", "amount": 100000.00},  -- Несуществующий IIN
        {"iin": "987654321101", "amount": 100000.00}
    ]'::JSONB,
    'Test with errors'
);

-- Проверка результатов
SELECT * FROM salary_batch_report;
SELECT * FROM transactions WHERE type = 'transfer' ORDER BY created_at DESC LIMIT 10;
SELECT account_number, balance FROM accounts WHERE customer_id >= 11;

/*
ARCHITECTURE DECISIONS:
Процедура перевода (Task 1):
- SELECT FOR UPDATE для защиты от гонок
- Полный ROLLBACK при ошибках 
- Конвертация в KZT для проверки лимитов
- Детальное логирование всех операций
- Коды ошибок п

Индексы (Task 3):
- Covering index для проверки лимита 
- Hash индекс для account_number 
- Partial index только для активных счетов
- Expression index для поиска по email
- GIN для JSONB полей в логах

Materialized View (Task 4):
- Кэширует отчеты по зарплатным пакетам
- Обновляется при новых batch операциях
- Индекс по дате для быстрого доступа

*/