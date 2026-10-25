select
    {{ to_int('id') }}      as inventory_id,
    {{ to_int('version') }} as inventory_version,
    set_num
from {{ source('rebrickable', 'inventories') }}
