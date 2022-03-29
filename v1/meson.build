custom_target(
    'build',
    build_by_default: true,
    input: 'mkdocs.yml',
    output: 'site',
    command: [
        mkdocs,
        'build',
        get_option('werror') ? '--strict' : [],
        '--config-file',
        '@INPUT@',
        '--site-dir',
        meson.project_build_root() / '@OUTPUT@',
    ]
)

deploy_v1 = run_target(
    'deploy-v1',
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
            meson.current_source_dir() / 'mkdocs.yml',
            '1.x',
        ]),
    ]
)

run_target(
    'serve-v1',
    command: [
        sh,
        '-c',
        ' '.join([
            mkdocs.full_path(),
            'serve',
            get_option('werror') ? '--strict' : [],
            '--dev-addr',
            '"${HSE_MKDOCS_SERVE_DEV_ADDR:-localhost:8000}"',
            '--config-file',
            meson.current_source_dir() / 'mkdocs.yml',
        ]),
    ]
)
