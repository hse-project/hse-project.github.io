project(
    'hse-project.github.io',
    default_options: [
        # Meson for whatever reason chooses not to respect HSE's default
        # options :).
        'force_fallback_for=xxhash,lz4,cjson',
    ],
    meson_version: '>= 0.60.0'
)

apis = []
if 'all' in get_option('apis')
    assert(get_option('apis').length() == 1, 'The -Dapis=none option cannot have additional values')
    apis += 'c'
elif 'none' in get_option('apis')
    assert(get_option('apis').length() == 1, 'The -Dapis=none option cannot have additional values')
    apis = []
elif 'auto' in get_option('apis')
    assert(get_option('apis').length() == 1, 'The -Dapis=auto option cannot have additional values')
    apis = get_option('apis')
else
    apis = get_option('apis')
endif

sh = find_program('sh')
ln = find_program('ln')
mike = find_program('mike')
mkdocs = find_program('mkdocs')
doxybook2 = find_program('doxybook2', required: false)
if not doxybook2.found() and ('auto' in apis or 'c' in apis)
    doxybook2_proj = subproject(
        'doxybook2',
        required: 'c' in apis,
        default_options: [
            'cpp_std=c++17',
        ]
    )

    doxybook2 = doxybook2_proj.get_variable('doxybook2')
endif

subdir('v2')
subdir('v3')

alias_target(
    'deploy',
    deploy_v2,
    deploy_v3
)

serve_config_file_path = v3_mkdocs_yml.full_path()
run_target(
    'serve',
    command: [
        sh,
        '-c',
        ' '.join([
            mike.full_path(),
            'serve',
            '--branch',
            '"${HSE_DEPLOY_BRANCH:-gh-pages}"',
            '--dev-addr',
            '"${HSE_SERVE_DEV_ADDR:-localhost:8000}"',
            '--config-file',
            serve_config_file_path,
        ])
    ]
)
