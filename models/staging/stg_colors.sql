select
    {{ to_int('id') }}         as color_id,
    name                       as color_name,
    concat('#', rgb)           as rgb_hex,
    {{ to_bool('is_trans') }}  as is_transparent
from {{ source('rebrickable', 'colors') }}
