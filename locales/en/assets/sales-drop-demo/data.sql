INSERT INTO sales_drop_daily
(sales_drop_id, observation_date, region, channel, product_category, campaign_name, severity, root_cause, action_owner, net_sales_amount, prior_week_net_sales_amount, sales_drop_amount, sales_drop_rate, order_count, visitor_count, conversion_rate, refund_amount, notes)
VALUES
(1, '2026-06-10', 'East China', 'Online', 'Home Appliance', '618 Warmup', 'HIGH', 'traffic_drop', 'Growth Ops', 182000.00, 260000.00, 78000.00, 0.3000, 920, 46000, 0.0200, 8200.00, 'Paid search traffic fell after bid cap change.'),
(2, '2026-06-10', 'North China', 'Offline', 'Mobile Phone', 'Store Weekend', 'MEDIUM', 'stockout', 'Supply Chain', 145000.00, 188000.00, 43000.00, 0.2287, 410, 9800, 0.0418, 3900.00, 'Two popular SKUs unavailable in flagship stores.'),
(3, '2026-06-10', 'South China', 'Online', 'Beauty', 'Member Day', 'LOW', 'refund_spike', 'Customer Care', 98000.00, 112000.00, 14000.00, 0.1250, 760, 39000, 0.0195, 15600.00, 'Refunds rose after delayed shipment complaints.'),
(4, '2026-06-11', 'East China', 'Marketplace', 'Home Appliance', '618 Warmup', 'HIGH', 'price_competition', 'Category Team', 171000.00, 255000.00, 84000.00, 0.3294, 870, 44000, 0.0198, 9100.00, 'Competitor coupon undercut promoted products.'),
(5, '2026-06-11', 'West China', 'Online', 'Outdoor', 'Summer Gear', 'MEDIUM', 'traffic_drop', 'Growth Ops', 76000.00, 104000.00, 28000.00, 0.2692, 380, 21000, 0.0181, 2500.00, 'Landing page click-through rate declined.'),
(6, '2026-06-11', 'North China', 'Offline', 'Mobile Phone', 'Store Weekend', 'HIGH', 'stockout', 'Supply Chain', 118000.00, 190000.00, 72000.00, 0.3789, 330, 9300, 0.0355, 4200.00, 'Stockout continued in three stores.'),
(7, '2026-06-12', 'South China', 'Marketplace', 'Beauty', 'Flash Sale', 'MEDIUM', 'price_competition', 'Category Team', 88000.00, 124000.00, 36000.00, 0.2903, 690, 35000, 0.0197, 7600.00, 'Platform coupon rules changed.'),
(8, '2026-06-12', 'East China', 'Online', 'Home Appliance', '618 Warmup', 'CRITICAL', 'traffic_drop', 'Growth Ops', 132000.00, 262000.00, 130000.00, 0.4962, 650, 36000, 0.0181, 11500.00, 'Ad delivery paused for several high-volume keywords.');
