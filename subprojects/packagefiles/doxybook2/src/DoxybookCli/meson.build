doxybook2 = executable(
    'doxybook2',
    files('main.cpp'),
    cpp_args: [
        '-DSPDLOG_FMT_EXTERNAL',
    ],
    dependencies: [
        cxxopts_dep,
        fmt_dep,
        libdoxybook2_dep,
        nlohmann_json_dep,
        spdlog_dep,
    ],
    native: true
)
