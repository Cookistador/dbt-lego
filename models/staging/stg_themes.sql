select
    {{ to_int('id') }}        as theme_id,
    name                      as theme_name,
    {{ to_int('parent_id') }} as parent_theme_id
from {{ source('rebrickable', 'themes') }}
