CREATE DATABASE project;
USE project;
CREATE TABLE regions (
    region_id    INT PRIMARY KEY,
    city         VARCHAR(50) NOT NULL,
    state        VARCHAR(50) NOT NULL,
    zone         VARCHAR(10) NOT NULL
);
CREATE TABLE marketing_campaigns (
    campaign_id  INT PRIMARY KEY,
    campaign_name VARCHAR(100) NOT NULL,
    channel      VARCHAR(30) NOT NULL,
    start_date   DATE NOT NULL,
    budget       DECIMAL(12,2) NOT NULL
);
CREATE TABLE plans (
    plan_id        INT PRIMARY KEY,
    plan_name      VARCHAR(40) NOT NULL,
    monthly_price  DECIMAL(10,2) NOT NULL,
    data_limit_gb  INT NOT NULL,
    tier           VARCHAR(10) NOT NULL
);
CREATE TABLE addons (
    addon_id       INT PRIMARY KEY,
    addon_name     VARCHAR(50) NOT NULL,
    monthly_price  DECIMAL(10,2) NOT NULL
);
CREATE TABLE discounts (
    discount_id       INT PRIMARY KEY,
    code              VARCHAR(20) NOT NULL UNIQUE,
    discount_percent  DECIMAL(5,2) NOT NULL,
    valid_from        DATE NOT NULL,
    valid_to          DATE NOT NULL
);
CREATE TABLE payment_methods (
    method_id    INT PRIMARY KEY,
    method_name  VARCHAR(30) NOT NULL
);
CREATE TABLE ticket_categories (
    category_id     INT PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL,
    priority_level  VARCHAR(10) NOT NULL
);
CREATE TABLE cancellation_reasons (
    reason_id        INT PRIMARY KEY,
    reason_text      VARCHAR(100) NOT NULL,
    reason_category  VARCHAR(30) NOT NULL
);
CREATE TABLE support_agents (
    agent_id    INT PRIMARY KEY,
    agent_name  VARCHAR(60) NOT NULL,
    team        VARCHAR(30) NOT NULL,
    hire_date   DATE NOT NULL
);
CREATE TABLE customers (
    customer_id    INT PRIMARY KEY,
    first_name     VARCHAR(40) NOT NULL,
    last_name      VARCHAR(40) NOT NULL,
    gender         VARCHAR(10) NOT NULL,
    date_of_birth  DATE NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,
    phone          VARCHAR(15) NOT NULL,
    signup_date    DATE NOT NULL,
    campaign_id    INT,
    FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(campaign_id)
);
CREATE TABLE customer_addresses (
    address_id    INT PRIMARY KEY,
    customer_id   INT NOT NULL,
    address_line  VARCHAR(150) NOT NULL,
    region_id     INT NOT NULL,
    pincode       VARCHAR(10) NOT NULL,
    is_primary    TINYINT(1) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);
CREATE TABLE subscriptions (
    subscription_id  INT PRIMARY KEY,
    customer_id      INT NOT NULL,
    plan_id          INT NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE,
    status           VARCHAR(10) NOT NULL,      
    contract_type    VARCHAR(20) NOT NULL,      
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);
CREATE TABLE subscription_addons (
    sub_addon_id     INT PRIMARY KEY,
    subscription_id  INT NOT NULL,
    addon_id         INT NOT NULL,
    added_date       DATE NOT NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    FOREIGN KEY (addon_id) REFERENCES addons(addon_id)
);
CREATE TABLE usage_logs (
    usage_id         INT PRIMARY KEY,
    subscription_id  INT NOT NULL,
    usage_month      DATE NOT NULL,             
    data_used_gb     DECIMAL(8,2) NOT NULL,
    call_minutes     INT NOT NULL,
    sms_count        INT NOT NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);
CREATE TABLE invoices (
    invoice_id       INT PRIMARY KEY,
    subscription_id  INT NOT NULL,
    invoice_date     DATE NOT NULL,
    due_date         DATE NOT NULL,
    subtotal         DECIMAL(10,2) NOT NULL,
    discount_id      INT,
    discount_amount  DECIMAL(10,2) NOT NULL,
    tax_amount       DECIMAL(10,2) NOT NULL,
    total_amount     DECIMAL(10,2) NOT NULL,
    status           VARCHAR(10) NOT NULL,      
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    FOREIGN KEY (discount_id) REFERENCES discounts(discount_id)
);
CREATE TABLE invoice_items (
    item_id      INT PRIMARY KEY,
    invoice_id   INT NOT NULL,
    description  VARCHAR(100) NOT NULL,
    quantity     INT NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,
    line_total   DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);
CREATE TABLE payments (
    payment_id    INT PRIMARY KEY,
    invoice_id    INT NOT NULL,
    method_id     INT NOT NULL,
    payment_date  DATE NOT NULL,
    amount        DECIMAL(10,2) NOT NULL,
    status        VARCHAR(10) NOT NULL,         
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (method_id) REFERENCES payment_methods(method_id)
);
CREATE TABLE support_tickets (
    ticket_id           INT PRIMARY KEY,
    customer_id         INT NOT NULL,
    category_id         INT NOT NULL,
    agent_id            INT NOT NULL,
    created_at          DATETIME NOT NULL,
    resolved_at         DATETIME,
    status              VARCHAR(10) NOT NULL,   
    satisfaction_score  INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (category_id) REFERENCES ticket_categories(category_id),
    FOREIGN KEY (agent_id) REFERENCES support_agents(agent_id)
);
CREATE TABLE nps_feedback (
    feedback_id  INT PRIMARY KEY,
    customer_id  INT NOT NULL,
    survey_date  DATE NOT NULL,
    nps_score    INT NOT NULL,                 
    comment_text VARCHAR(200),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE churn_events (
    churn_id         INT PRIMARY KEY,
    subscription_id  INT NOT NULL,
    customer_id      INT NOT NULL,
    churn_date       DATE NOT NULL,
    reason_id        INT NOT NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (reason_id) REFERENCES cancellation_reasons(reason_id)
);