hse_2_proj = subproject(
    'hse-2',
    required: 'c' in apis,
    default_options: [
        'warning_level=0',
        'default_library=static',
        'cli=false',
        'docs=enabled',
        'tests=false',
        'tools=disabled',
        'samples=false',
        'bindings=none',
        'db_bench=false',
    ]
)

if not hse_2_proj.found()
    subdir_done()
endif

# This is a bug in HSE 2.1, where the doxygen variable got overridden to the
# generated docs. Unless HSE 2.1 has another release after 2.1.1, forget about
# this.
c_doxygen = hse_2_proj.get_variable('doxygen')

generated_docs += custom_target(
    'c-doxybook2',
    build_by_default: true,
    output: '.',
    command: [
        doxybook2,
        '--input',
        # This must be kept in sync with HSE. Note the version in the path.
        meson.project_build_root() / 'subprojects/hse-r2.1.1/docs/doxygen/api/xml',
        '--output',
        '@OUTPUT@',
        '--config',
        meson.current_source_dir() / '../.doxybook/config.json',
        '--templates',
        meson.current_source_dir() / '../.doxybook/templates'
    ],
    depends: [
        c_doxygen,
    ]
)
