project(
    'doxybook2',
    'cpp',
    version: '1.4.0',
    license: 'MIT',
    default_options: [
        'cpp_std=c++17',
    ]
)

cpp = meson.get_compiler('cpp', native: true)

catch2_dep = dependency(
    'catch2',
    version: '>= 2.13.6',
    native: true,
    required: get_option('tests')
)
fmt_dep = dependency(
    'fmt',
    native: true,
    version: '>= 8.0.1'
)
inja_dep = dependency(
    'inja',
    native: true,
    version: '>= 3.3.0',
    default_options: [
        'tests=false',
    ]
)
nlohmann_json_dep = dependency(
    'nlohmann_json',
    native: true,
    version: '>= 3.9.1'
)
spdlog_dep = dependency(
    'spdlog',
    native: true,
    version: '>= 1.9.1'
)
if not cpp.has_header('cxxopts.hpp')
    cxxopts_proj = subproject('cxxopts')

    cxxopts_dep = cxxopts_proj.get_variable('cxxopts_dep')
else
    cxxopts_dep = dependency('', required: false)
endif
if cpp.get_id() == 'msvc'
    dirent_dep = dependency(
        'dirent',
        native: true,
        version: '>= 1.23.2'
    )
else
    dirent_dep = dependency('', required: false)
endif

subdir('include')
subdir('src/Doxybook')
subdir('src/DoxybookCli')
