/**
 * Sales-drop daily diagnostic fixture.
 *
 * Single-table SQLite model for local Foggy AI analysis demos.
 */
export const model = {
    name: 'SalesDropDailyModel',
    caption: 'Sales Drop Daily Diagnostics',
    tableName: 'sales_drop_daily',
    idColumn: 'sales_drop_id',

    properties: [
        {
            column: 'sales_drop_id',
            caption: 'Sales Drop Record ID',
            type: 'LONG'
        },
        {
            column: 'observation_date',
            name: 'observationDate',
            caption: 'Observation Date',
            description: 'Business date for the sales-drop diagnostic row. Use it to compare current sales with prior-week sales.',
            type: 'DATE'
        },
        {
            column: 'region',
            caption: 'Region',
            description: 'Sales region. Use this field to locate whether a drop is concentrated in a specific region.',
            type: 'STRING'
        },
        {
            column: 'channel',
            caption: 'Channel',
            description: 'Sales channel, such as Online, Offline, or Marketplace.',
            type: 'STRING'
        },
        {
            column: 'product_category',
            name: 'productCategory',
            caption: 'Product Category',
            description: 'Top-level product category. Use this field to identify category-level concentration of the sales drop.',
            type: 'STRING'
        },
        {
            column: 'campaign_name',
            name: 'campaignName',
            caption: 'Campaign Name',
            description: 'Related campaign name. Use this field to inspect whether campaign performance declined.',
            type: 'STRING'
        },
        {
            column: 'severity',
            caption: 'Severity',
            description: 'Sales-drop severity: LOW, MEDIUM, HIGH, or CRITICAL.',
            type: 'STRING'
        },
        {
            column: 'root_cause',
            name: 'rootCause',
            caption: 'Root Cause',
            description: 'Initial root-cause label, such as traffic_drop, stockout, price_competition, or refund_spike.',
            type: 'STRING'
        },
        {
            column: 'action_owner',
            name: 'actionOwner',
            caption: 'Action Owner',
            description: 'Team or role that should follow up the sales-drop issue first.',
            type: 'STRING'
        },
        {
            column: 'notes',
            caption: 'Diagnostic Notes',
            description: 'Additional explanation for the sales drop. Useful for narrative answers.',
            type: 'STRING'
        }
    ],

    measures: [
        {
            column: 'net_sales_amount',
            name: 'netSalesAmount',
            caption: 'Current Net Sales Amount',
            description: 'Net sales amount on the observation date.',
            aggregation: 'sum',
            type: 'MONEY'
        },
        {
            column: 'prior_week_net_sales_amount',
            name: 'priorWeekNetSalesAmount',
            caption: 'Prior Week Net Sales Amount',
            description: 'Prior-week comparable net sales amount. Use this field to calculate the sales drop.',
            aggregation: 'sum',
            type: 'MONEY'
        },
        {
            column: 'sales_drop_amount',
            name: 'salesDropAmount',
            caption: 'Sales Drop Amount',
            description: 'Prior-week net sales minus current net sales. Larger values mean a more severe absolute sales drop.',
            aggregation: 'sum',
            type: 'MONEY'
        },
        {
            column: 'sales_drop_rate',
            name: 'salesDropRate',
            caption: 'Sales Drop Rate',
            description: 'Sales drop amount divided by prior-week net sales. This is a row-level ratio; interpret cross-row aggregation carefully.',
            type: 'DECIMAL'
        },
        {
            column: 'order_count',
            name: 'orderCount',
            caption: 'Order Count',
            aggregation: 'sum',
            type: 'INTEGER'
        },
        {
            column: 'visitor_count',
            name: 'visitorCount',
            caption: 'Visitor Count',
            aggregation: 'sum',
            type: 'INTEGER'
        },
        {
            column: 'conversion_rate',
            name: 'conversionRate',
            caption: 'Conversion Rate',
            description: 'Orders divided by visitors. This is a row-level ratio; interpret cross-row aggregation carefully.',
            type: 'DECIMAL'
        },
        {
            column: 'refund_amount',
            name: 'refundAmount',
            caption: 'Refund Amount',
            aggregation: 'sum',
            type: 'MONEY'
        }
    ]
};
