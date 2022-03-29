libdoxybook2 = static_library(
    'doxybook2',
    files(
        'Config.cpp',
        'DefaultTemplates.cpp',
        'Doxygen.cpp',
        'Enums.cpp',
        'Generator.cpp',
        'JsonConverter.cpp',
        'Node.cpp',
        'Renderer.cpp',
        'TextMarkdownPrinter.cpp',
        'TextPlainPrinter.cpp',
        'Utils.cpp',
        'Xml.cpp',
        'XmlTextParser.cpp',
        'tinyxml2/tinyxml2.cpp'
    ),
    include_directories: [
        doxybook2_includes,
        include_directories('.'),
    ],
    dependencies: [
        fmt_dep,
        spdlog_dep,
        inja_dep,
        nlohmann_json_dep,
        dirent_dep,
    ],
    native: true
)

libdoxybook2_dep = declare_dependency(
    link_with: libdoxybook2,
    include_directories: doxybook2_includes
)
