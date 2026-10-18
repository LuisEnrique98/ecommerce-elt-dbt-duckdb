select
    p.product_id,
    p.category_name,
    coalesce(t.category_name_en, p.category_name) as category_name_en,
    p.weight_g,
    p.length_cm,
    p.height_cm,
    p.width_cm
from {{ ref('stg_products') }} p
left join {{ ref('stg_category_translation') }} t
    on t.category_name = p.category_name