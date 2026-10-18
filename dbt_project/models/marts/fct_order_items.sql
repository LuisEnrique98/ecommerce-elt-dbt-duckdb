select
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    o.customer_id,
    cast(o.purchased_at as date) as purchase_date,
    o.order_status,
    i.price,
    i.freight_value,
    i.price + i.freight_value as total_item_value,
    case
        when o.delivered_at is not null
        then date_diff('day', o.purchased_at, o.delivered_at)
    end as delivery_days,
    case
        when o.delivered_at is null then null
        else o.delivered_at > o.estimated_delivery_at
    end as is_late
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders') }} o
    on o.order_id = i.order_id