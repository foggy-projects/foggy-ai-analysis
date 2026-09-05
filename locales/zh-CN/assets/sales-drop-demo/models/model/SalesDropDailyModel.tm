/**
 * Sales-drop daily diagnostic fixture.
 *
 * Single-table SQLite model for local Foggy AI analysis demos.
 */
import { dicts } from '../dicts.fsscript';

export const model = {
    name: 'SalesDropDailyModel',
    caption: 'Sales Drop Daily Diagnostics',
    tableName: 'sales_drop_daily',
    idColumn: 'sales_drop_id',

    dimensions: [
        {
            name: 'observationDate',
            foreignKey: 'observation_date',
            primaryKey: 'observation_date',
            captionColumn: 'observation_date',
            caption: 'Observation Date',
            description: 'Self date dimension backed by sales_drop_daily.observation_date without joining a date table.',
            type: 'DAY',
            timeRole: 'business_date',
            recommendedUse: 'Primary time axis for sales-drop trends, period filters, pivots, and time-window analysis.',
            properties: [
                {
                    column: 'observation_date',
                    name: 'year',
                    caption: 'Observation Year',
                    type: 'INTEGER',
                    dialectFormulaDef: {
                        sqlite: { builder: (alias) => { return `CAST(strftime('%Y', ${alias}.observation_date) AS INTEGER)`; } }
                    }
                },
                {
                    column: 'observation_date',
                    name: 'month',
                    caption: 'Observation Month',
                    type: 'INTEGER',
                    dialectFormulaDef: {
                        sqlite: { builder: (alias) => { return `CAST(strftime('%m', ${alias}.observation_date) AS INTEGER)`; } }
                    }
                },
                {
                    column: 'observation_date',
                    name: 'yearMonth',
                    caption: 'Observation Year-Month',
                    type: 'STRING',
                    dialectFormulaDef: {
                        sqlite: { builder: (alias) => { return `strftime('%Y-%m', ${alias}.observation_date)`; } }
                    }
                }
            ]
        }
    ],

    properties: [
        {
            column: 'sales_drop_id',
            caption: 'Sales Drop Record ID',
            type: 'LONG'
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
            column: 'customer_id',
            name: 'customerId',
            caption: 'Customer ID',
            description: 'Stable customer identifier for ranking sales drops by customer.',
            type: 'STRING'
        },
        {
            column: 'customer_name',
            name: 'customerName',
            caption: 'Customer Name',
            description: 'Customer display name. Use this field when the user asks which customers declined or dropped the most.',
            type: 'STRING'
        },
        {
            column: 'customer_segment',
            name: 'customerSegment',
            caption: 'Customer Segment',
            description: 'Customer segment such as Enterprise, Retail, or VIP.',
            type: 'STRING'
        },
        {
            column: 'severity',
            caption: 'Severity',
            description: 'Sales-drop severity: LOW, MEDIUM, HIGH, or CRITICAL.',
            type: 'STRING',
            dictRef: dicts.severity
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
