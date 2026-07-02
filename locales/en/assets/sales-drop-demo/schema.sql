DROP TABLE IF EXISTS sales_drop_daily;

CREATE TABLE sales_drop_daily
(
    sales_drop_id                 INTEGER NOT NULL PRIMARY KEY,
    observation_date              TEXT    NOT NULL,
    region                        TEXT    NOT NULL,
    channel                       TEXT    NOT NULL,
    product_category              TEXT    NOT NULL,
    campaign_name                 TEXT,
    severity                      TEXT    NOT NULL,
    root_cause                    TEXT    NOT NULL,
    action_owner                  TEXT    NOT NULL,
    net_sales_amount              REAL    NOT NULL,
    prior_week_net_sales_amount   REAL    NOT NULL,
    sales_drop_amount             REAL    NOT NULL,
    sales_drop_rate               REAL    NOT NULL,
    order_count                   INTEGER NOT NULL,
    visitor_count                 INTEGER NOT NULL,
    conversion_rate               REAL    NOT NULL,
    refund_amount                 REAL    NOT NULL,
    notes                         TEXT
);

CREATE INDEX idx_sales_drop_date ON sales_drop_daily (observation_date);
CREATE INDEX idx_sales_drop_region ON sales_drop_daily (region);
CREATE INDEX idx_sales_drop_channel ON sales_drop_daily (channel);
CREATE INDEX idx_sales_drop_severity ON sales_drop_daily (severity);
CREATE INDEX idx_sales_drop_root_cause ON sales_drop_daily (root_cause);
