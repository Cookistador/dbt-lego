select
    {{ to_int('inventory_id') }} as inventory_id,
    part_num,
    {{ to_int('color_id') }}     as color_id,
    {{ to_int('quantity') }}     as quantity,
    {{ to_bool('is_spare') }}    as is_spare
from {{ source('rebrickable', 'inventory_parts') }}
