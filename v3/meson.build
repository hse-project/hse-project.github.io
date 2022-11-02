links = []
generated_docs = []

v3_mkdocs_yml = custom_target(
    'link-mkdocs.yml',
    input: 'mkdocs.yml',
    output: 'mkdocs.yml',
    command: [
        'ln',
        '--symbolic',
        '--force',
        meson.current_source_dir() / '@INPUT@',
        '@OUTPUT@',
    ]
)

subdir('docs')

custom_target(
    'build',
    build_by_default: true,
    input: v3_mkdocs_yml,
    output: 'site',
    command: [
        mkdocs,
        'build',
        get_option('werror') ? '--strict' : [],
        '--config-file',
        '@INPUT@',
        '--site-dir',
        '@OUTPUT@'
    ],
    depends: [
        links,
        generated_docs,
    ]
)

deploy_v3 = run_target(
    'deploy-v3',
    command: [
        sh,
        '-c',
        ' '.join([
            mike.full_path(),
            'deploy',
            '--remote',
            '"${HSE_DEPLOY_REMOTE:-origin}"',
            '--branch',
            '"${HSE_DEPLOY_BRANCH:-gh-pages}"',
            '--config-file',
            v3_mkdocs_yml.full_path(),
            '3.x',
        ]),
    ],
    depends: [
        v3_mkdocs_yml,
        links,
        generated_docs,
    ]
)

run_target(
    'serve-v3',
    command: [
        sh,
        '-c',
        ' '.join([
            mkdocs.full_path(),
            'serve',
            get_option('werror') ? '--strict' : [],
            '--dev-addr',
            '"${HSE_SERVE_DEV_ADDR:-localhost:8000}"',
            '--config-file',
            v3_mkdocs_yml.full_path(),
        ]),
    ],
    depends: [
        v3_mkdocs_yml,
        links,
        generated_docs,
    ]
)
