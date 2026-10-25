select
    set_num,
    name                      as set_name,
    {{ to_int('year') }}      as release_year,
    {{ to_int('theme_id') }}  as theme_id,
    {{ to_int('num_parts') }} as num_parts,
    img_url
from {{ source('rebrickable', 'sets') }}
