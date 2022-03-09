import qbs 1.0
import qbs.Probes as Probes

DynamicLibrary {
    targetName: "tiled"

    Depends { name: "cpp" }
    Depends { name: "Qt"; submodules: "gui"; versionAtLeast: "5.12" }

    Properties {
        condition: !qbs.toolchain.contains("msvc")
        cpp.dynamicLibraries: base.concat(["z"])
    }

    Probes.PkgConfigProbe {
        id: pkgConfigZstd
        name: "libzstd"
    }

    cpp.cxxLanguageVersion: "c++17"
    cpp.visibility: "minimal"
    cpp.defines: {
        var defs = [
            "TILED_LIBRARY",
            "QT_NO_CAST_FROM_ASCII",
            "QT_NO_CAST_TO_ASCII",
            "QT_NO_URL_CAST_FROM_STRING",
            "QT_DISABLE_DEPRECATED_BEFORE=QT_VERSION_CHECK(5,15,0)",
            "QT_NO_DEPRECATED_WARNINGS",
            "_USE_MATH_DEFINES",
        ]

        if (project.enableZstd || pkgConfigZstd.found)
            defs.push("TILED_ZSTD_SUPPORT");

        return defs;
    }

    Properties {
        condition: qbs.targetOS.contains("macos")
        cpp.cxxFlags: ["-Wno-unknown-pragmas"]
    }

    Properties {
        condition: !project.enableZstd && pkgConfigZstd.found
        cpp.cxxFlags: pkgConfigZstd.cflags
        cpp.linkerFlags: pkgConfigZstd.libs
    }

    Properties {
        condition: project.enableZstd
        cpp.staticLibraries: ["zstd"]
        cpp.libraryPaths: ["../../zstd/lib"]
        cpp.includePaths: ["../../zstd/lib"]
    }

    Properties {
        condition: qbs.targetOS.contains("darwin")
        bundle.isBundle: false
        cpp.sonamePrefix: "@rpath"
    }

    files: [
        "compression.cpp",
        "compression.h",
        "containerhelpers.h",
        "fileformat.cpp",
        "fileformat.h",
        "filesystemwatcher.cpp",
        "filesystemwatcher.h",
        "gidmapper.cpp",
        "gidmapper.h",
        "grid.h",
        "grouplayer.cpp",
        "grouplayer.h",
        "hex.cpp",
        "hex.h",
        "hexagonalrenderer.cpp",
        "hexagonalrenderer.h",
        "imagecache.cpp",
        "imagecache.h",
        "imagelayer.cpp",
        "imagelayer.h",
        "imagereference.cpp",
        "imagereference.h",
        "isometricrenderer.cpp",
        "isometricrenderer.h",
        "layer.cpp",
        "layer.h",
        "logginginterface.cpp",
        "logginginterface.h",
        "map.cpp",
        "map.h",
        "mapformat.cpp",
        "mapformat.h",
        "mapobject.cpp",
        "mapobject.h",
        "mapreader.cpp",
        "mapreader.h",
        "maprenderer.cpp",
        "maprenderer.h",
        "maptovariantconverter.cpp",
        "maptovariantconverter.h",
        "mapwriter.cpp",
        "mapwriter.h",
        "minimaprenderer.cpp",
        "minimaprenderer.h",
        "object.cpp",
        "object.h",
        "objectgroup.cpp",
        "objectgroup.h",
        "objecttemplate.cpp",
        "objecttemplate.h",
        "objecttemplateformat.cpp",
        "objecttemplateformat.h",
        "objecttypes.cpp",
        "objecttypes.h",
        "orthogonalrenderer.cpp",
        "orthogonalrenderer.h",
        "plugin.cpp",
        "plugin.h",
        "pluginmanager.cpp",
        "pluginmanager.h",
        "properties.cpp",
        "properties.h",
        "propertytype.cpp",
        "propertytype.h",
        "savefile.cpp",
        "savefile.h",
        "staggeredrenderer.cpp",
        "staggeredrenderer.h",
        "templatemanager.cpp",
        "templatemanager.h",
        "tile.cpp",
        "tileanimationdriver.cpp",
        "tileanimationdriver.h",
        "tiled.cpp",
        "tiled_global.h",
        "tiled.h",
        "tile.h",
        "tilelayer.cpp",
        "tilelayer.h",
        "tileset.cpp",
        "tileset.h",
        "tilesetformat.cpp",
        "tilesetformat.h",
        "tilesetmanager.cpp",
        "tilesetmanager.h",
        "varianttomapconverter.cpp",
        "varianttomapconverter.h",
        "wangset.cpp",
        "wangset.h",
        "worldmanager.cpp",
        "worldmanager.h",
    ]

    Group {
        condition: project.installHeaders
        qbs.install: true
        qbs.installDir: "include/tiled"
        fileTagsFilter: "hpp"
    }

    Export {
        Depends { name: "cpp" }
        Depends {
            name: "Qt"
            submodules: ["gui"]
        }

        cpp.includePaths: "."
    }

    Group {
        condition: !qbs.targetOS.contains("darwin")
        qbs.install: true
        qbs.installDir: {
            if (qbs.targetOS.contains("windows"))
                return ""
            else
                return "lib"
        }
        fileTagsFilter: "dynamiclibrary"
    }
}
