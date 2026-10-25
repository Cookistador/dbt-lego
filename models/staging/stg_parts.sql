select
    part_num,
    name                        as part_name,
    {{ to_int('part_cat_id') }} as part_category_id
from {{ source('rebrickable', 'parts') }}
