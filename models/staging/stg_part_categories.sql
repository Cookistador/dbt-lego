select
    {{ to_int('id') }} as part_category_id,
    name               as part_category_name
from {{ source('rebrickable', 'part_categories') }}
