--ПОЛЬЗОВАТЕЛИ 
CREATE TABLE wiki_users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--СТАТЬИ 
CREATE TABLE wiki_articles (
    article_id SERIAL PRIMARY KEY,
    article_title VARCHAR(500) NOT NULL,
    article_content TEXT NOT NULL,
    created_by_user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_published BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (created_by_user_id) REFERENCES wiki_users(user_id)
);

-- КАТЕГОРИИ 
CREATE TABLE wiki_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(200) NOT NULL UNIQUE,
    category_description TEXT
);

--СВЯЗЬ СТАТЬИ-КАТЕГОРИИ 
CREATE TABLE article_categories (
    article_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    PRIMARY KEY (article_id, category_id),
    FOREIGN KEY (article_id) REFERENCES wiki_articles(article_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES wiki_categories(category_id) ON DELETE CASCADE
);

--ТЕГИ 
CREATE TABLE wiki_tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(100) NOT NULL UNIQUE
);

--СВЯЗЬ СТАТЬИ-ТЕГИ
CREATE TABLE article_tags (
    article_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (article_id, tag_id),
    FOREIGN KEY (article_id) REFERENCES wiki_articles(article_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES wiki_tags(tag_id) ON DELETE CASCADE
);

--КОММЕНТАРИИ
CREATE TABLE article_comments (
    comment_id SERIAL PRIMARY KEY,
    article_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (article_id) REFERENCES wiki_articles(article_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES wiki_users(user_id)
);

--ИЗБРАННОЕ
CREATE TABLE user_favorites (
    favorite_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    article_id INTEGER NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, article_id),
    FOREIGN KEY (user_id) REFERENCES wiki_users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES wiki_articles(article_id) ON DELETE CASCADE
);

--РЕЙТИНГИ 
CREATE TABLE article_ratings (
    rating_id SERIAL PRIMARY KEY,
    article_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating_value INTEGER CHECK (rating_value BETWEEN 1 AND 5),
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(article_id, user_id),
    FOREIGN KEY (article_id) REFERENCES wiki_articles(article_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES wiki_users(user_id)
);

-- ТРИГГЕРЫ
-- Функция для обновления updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для статей
CREATE TRIGGER trigger_update_article_time 
    BEFORE UPDATE ON wiki_articles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_modified_column();

-- Триггер для комментариев
CREATE TRIGGER trigger_update_comment_time 
    BEFORE UPDATE ON article_comments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_modified_column();

--ПОЛЬЗОВАТЕЛЕЙ
INSERT INTO wiki_users (username, email) VALUES
('alex_ivanov', 'alex.ivanov@example.com'),
('maria_petrova', 'maria.petrova@example.com'),
('sergey_sidorov', 'sergey.sidorov@example.com'),
('olga_kuznetsova', 'olga.kuznetsova@example.com'),
('dmitry_vorobev', 'dmitry.vorobev@example.com');

--КАТЕГОРИИ
INSERT INTO wiki_categories (category_name, category_description) VALUES
('Программирование', 'Языки программирования, фреймворки, алгоритмы'),
('Базы данных', 'SQL, NoSQL, проектирование БД, оптимизация'),
('Веб-разработка', 'Frontend, Backend, DevOps'),
('Кулинария', 'Рецепты, кулинарные техники, советы'),
('Здоровье и спорт', 'Фитнес, питание, wellness'),
('Финансы', 'Инвестиции, budgeting, трейдинг'),
('Путешествия', 'Советы путешественникам, маршруты'),
('Наука', 'Физика, математика, биология');

--ТЕГИ
INSERT INTO wiki_tags (tag_name) VALUES
('SQL'),
('Python'),
('JavaScript'),
('React'),
('PostgreSQL'),
('Docker'),
('Рецепт'),
('Фитнес'),
('Инвестиции'),
('Путешествия'),
('Наука'),
('Учебное'),
('Практика'),
('Теория'),
('Для начинающих'),
('Продвинутое'),
('Важно'),
('Срочно');

--4. СОЗДАЕМ СТАТЬИ (10 статей) 
INSERT INTO wiki_articles (article_title, article_content, created_by_user_id) VALUES
('Полное руководство по SQL для начинающих', 'SQL (Structured Query Language) - язык запросов для работы с реляционными базами данных. Основные команды: SELECT, INSERT, UPDATE, DELETE. JOIN-запросы: INNER JOIN, LEFT JOIN, RIGHT JOIN. Практические примеры и упражнения.', 1),
('Python в анализе данных: Pandas и NumPy', 'Библиотеки для анализа данных на Python. Pandas для работы с таблицами, NumPy для математических операций, Matplotlib для визуализации. Пример анализа реальных данных.', 2),
('Идеальная паста карбонара по-римски', 'Классический рецепт пасты карбонара. Ингредиенты: спагетти, панчетта, яйца, пекорино романо. Пошаговое приготовление, советы шефа.', 3),
('Утренний комплекс упражнений на 15 минут', 'Зарядка для бодрости на весь день. Разминка, приседания, отжимания, планка, выпады, скручивания. Польза для метаболизма и продуктивности.', 4),
('Основы инвестирования: с чего начать новичку', 'Путеводитель по миру инвестиций. Финансовая подушка безопасности, определение целей, инвестиционные инструменты, диверсификация, основные ошибки новичков.', 5),
('React для начинающих: компоненты и состояние', 'Введение в React.js. Создание компонентов, работа с состоянием (state), хуки (useState, useEffect), JSX синтаксис, работа с событиями.', 1),
('Docker для веб-разработчиков', 'Контейнеризация приложений с Docker. Dockerfile, образы, контейнеры, Docker Compose, работа с volumes, деплой приложений.', 2),
('Здоровое питание: основы и мифы', 'Принципы здорового питания. Баланс БЖУ, режим питания, распространенные мифы, примеры рациона, советы по приготовлению.', 3),
('Маршрут по Италии: Рим, Флоренция, Венеция', 'Путеводитель по Италии за 10 дней. Основные достопримечательности, транспорт, отели, местная кухня, бюджет поездки.', 4),
('Квантовая физика для начинающих', 'Основы квантовой механики. Волновая функция, принцип неопределенности, квантовые состояния, эксперимент с двумя щелями.', 5);

--СТАТЬИ К КАТЕГОРИЯМ 
INSERT INTO article_categories (article_id, category_id) VALUES
-- Статья 1 (SQL) → Программирование + Базы данных
(1, 1), (1, 2),
-- Статья 2 (Python) → Программирование
(2, 1),
-- Статья 3 (Паста) → Кулинария
(3, 4),
-- Статья 4 (Зарядка) → Здоровье и спорт
(4, 5),
-- Статья 5 (Инвестиции) → Финансы
(5, 6),
-- Статья 6 (React) → Веб-разработка + Программирование
(6, 3), (6, 1),
-- Статья 7 (Docker) → Веб-разработка
(7, 3),
-- Статья 8 (Питание) → Здоровье и спорт
(8, 5),
-- Статья 9 (Италия) → Путешествия
(9, 7),
-- Статья 10 (Квантовая физика) → Наука
(10, 8);

--СТАТЬИ К ТЕГАМ
INSERT INTO article_tags (article_id, tag_id) VALUES
-- Статья 1: SQL (теги 1,12,15)
(1, 1), (1, 12), (1, 15),
-- Статья 2: Python (теги 2,12,13)
(2, 2), (2, 12), (2, 13),
-- Статья 3: Паста (теги 7,13)
(3, 7), (3, 13),
-- Статья 4: Зарядка (теги 8,13,17)
(4, 8), (4, 13), (4, 17),
-- Статья 5: Инвестиции (теги 9,12,15)
(5, 9), (5, 12), (5, 15),
-- Статья 6: React (теги 3,4,12)
(6, 3), (6, 4), (6, 12),
-- Статья 7: Docker (теги 6,13,16)
(7, 6), (7, 13), (7, 16),
-- Статья 8: Питание (теги 13,17)
(8, 13), (8, 17),
-- Статья 9: Италия (теги 10,13)
(9, 10), (9, 13),
-- Статья 10: Квантовая физика (теги 11,14)
(10, 11), (10, 14);

--КОММЕНТАРИИ 
INSERT INTO article_comments (article_id, user_id, comment_text) VALUES
-- Комментарии к статье 1 (SQL)
(1, 2, 'Отличная статья! Очень понятно для новичков.'),
(1, 3, 'Не хватает примеров с оконными функциями.'),
(1, 4, 'Спасибо, очень полезный материал для подготовки к собеседованию.'),
-- Комментарии к статье 3 (Паста)
(3, 1, 'Пробовал готовить по этому рецепту - получилось восхитительно!'),
(3, 5, 'А можно заменить панчетту на обычный бекон?'),
-- Комментарии к статье 4 (Зарядка)
(4, 2, 'Делаю эту зарядку каждое утро уже месяц - чувствую себя прекрасно!'),
(4, 3, 'Для новичков лучше начинать с меньшего количества повторов.'),
-- Комментарии к статье 5 (Инвестиции)
(5, 1, 'Хорошая статья для тех, кто только начинает инвестировать.'),
(5, 4, 'Не согласен по поводу депозитов - инфляция съедает всю доходность.'),
-- Комментарии к статье 6 (React)
(6, 5, 'Отличное введение в React! Жду продолжения про Redux.'),
-- Комментарии к статье 9 (Италия)
(9, 1, 'Были по этому маршруту в прошлом году - незабываемо!'),
(9, 2, 'Советую добавить Сиену в маршрут - прекрасный город.');

--СТАТЬИ В ИЗБРАННОЕ
INSERT INTO user_favorites (user_id, article_id) VALUES
(1, 3), (1, 5), (1, 9),
(2, 1), (2, 4), (2, 7),
(3, 2), (3, 6), (3, 10),
(4, 3), (4, 8),
(5, 1), (5, 5), (5, 7);

--РЕЙТИНГИ
INSERT INTO article_ratings (article_id, user_id, rating_value) VALUES
-- Статья 1
(1, 1, 5), (1, 2, 4), (1, 3, 5),
-- Статья 2
(2, 4, 4), (2, 5, 5),
-- Статья 3
(3, 1, 5), (3, 2, 5), (3, 3, 4), (3, 4, 5), (3, 5, 5),
-- Статья 4
(4, 1, 4), (4, 2, 5), (4, 5, 4),
-- Статья 5
(5, 1, 5), (5, 2, 4), (5, 3, 3), (5, 4, 5),
-- Статья 6
(6, 2, 4), (6, 3, 5),
-- Статья 7
(7, 1, 5), (7, 4, 4), (7, 5, 5),
-- Статья 8
(8, 2, 4), (8, 3, 3),
-- Статья 9
(9, 1, 5), (9, 3, 5), (9, 4, 4),
-- Статья 10
(10, 2, 4), (10, 5, 5);