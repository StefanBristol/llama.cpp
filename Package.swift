// swift-tools-version: 6.0

import PackageDescription

var sources = [ "ggml/src/ggml.c",
                "ggml/src/gguf.cpp",
                "ggml/src/ggml-quants.c",
                "ggml/src/ggml-alloc.c",
                "ggml/src/ggml-backend.cpp",
                "ggml/src/ggml-threading.cpp",
                "ggml/src/ggml-backend-reg.cpp",
                "ggml/src/ggml-metal/ggml-metal.m",
                "ggml/src/ggml-blas/ggml-blas.cpp",
//                "ggml/src/ggml-aarch64.c",
                "ggml/src/ggml-cpu/ggml-cpu-aarch64.cpp",
                "ggml/src/ggml-cpu/ggml-cpu.c",
                "ggml/src/ggml-cpu/ggml-cpu.cpp",
                "ggml/src/ggml-cpu/ggml-cpu-quants.c",
                "ggml/src/ggml-cpu/ggml-cpu-traits.cpp",
                "ggml/src/ggml-cpu/llamafile/sgemm.cpp",
                
                "src/llama.cpp",
                "src/unicode.cpp",
                "src/unicode-data.cpp",
                "src/llama-grammar.cpp",
                "src/llama-vocab.cpp",
                "src/llama-sampling.cpp",
                "src/llama-context.cpp",
                "src/llama-kv-cache.cpp",
                "src/llama-mmap.cpp",
                "src/llama-quant.cpp",
                "src/llama-model.cpp",
                "src/llama-model-loader.cpp",
                "src/llama-impl.cpp",
                "src/llama-cparams.cpp",
                "src/llama-hparams.cpp",
                "src/llama-chat.cpp",
                "src/llama-batch.cpp",
                "src/llama-arch.cpp",
                "src/llama-adapter.cpp",
                
                "common/common.cpp",
                "common/log.cpp",
                "common/arg.cpp",
                "common/json-schema-to-grammar.cpp",
                "common/sampling.cpp",
                // "common/train.cpp",
                
                "examples/llava/llava.cpp",
                "examples/llava/clip.cpp",
                "examples/llava/llava-cli.cpp",
                // "examples/export-lora/export-lora.cpp",
                
//                "gpt_spm.cpp",
//                "package_helper.m",
//                "exception_helper_objc.mm",
//                "exception_helper.cpp",
                
                // "ggml_legacy/ggml_d925ed.c","ggml_legacy/ggml_d925ed-alloc.c","ggml_legacy/ggml_d925ed-metal.m","rwkv/rwkv.cpp",
                // "ggml_legacy/ggml_dadbed9.c","ggml_legacy/k_quants_dadbed9.c","ggml_legacy/ggml-alloc_dadbed9.c","ggml_legacy/ggml-metal_dadbed9.m",
                // "gptneox/gptneox.cpp","gpt2/gpt2.cpp","replit/replit.cpp","starcoder/starcoder.cpp","llama_legacy/llama_dadbed9.cpp",
                // "ggml_legacy/common_old.cpp",
                // "ggml_legacy/build-info.cpp",
                // "finetune/finetune.cpp",
                ]


// cSettings not currently used...
var cSettings: [CSetting] =  [
                .define("SWIFT_PACKAGE"),
                .define("GGML_USE_ACCELERATE"),
                .define("GGML_BLAS_USE_ACCELERATE"),
                .define("ACCELERATE_NEW_LAPACK"),
                .define("ACCELERATE_LAPACK_ILP64"),
                .define("GGML_USE_BLAS"),
//                .define("_DARWIN_C_SOURCE"),
                .define("GGML_USE_LLAMAFILE"),
                .define("GGML_METAL_NDEBUG"),
                .define("NDEBUG"),
                .define("GGML_USE_CPU"),
                .define("GGML_USE_METAL"),
                
//                .define("GGML_METAL_NDEBUG", .when(configuration: .release)),
//                .define("NDEBUG", .when(configuration: .release)),
                .unsafeFlags(["-Ofast"], .when(configuration: .release)),
                .unsafeFlags(["-O3"], .when(configuration: .debug)),
//                .unsafeFlags(["-mfma","-mfma","-mavx","-mavx2","-mf16c","-msse3","-mssse3"]), //for Intel CPU
//                .unsafeFlags(["-march=native","-mtune=native"],.when(platforms: [.macOS])),
//                .unsafeFlags(["-mcpu=apple-a14"],.when(platforms: [.iOS])),// use at your own risk, I've noticed more responsive work on 12 pro max
                .unsafeFlags(["-pthread"]),
//                .unsafeFlags(["-fno-objc-arc"]),
//                .unsafeFlags(["-fPIC"]),
                .unsafeFlags(["-Wno-shorten-64-to-32"]),
                .unsafeFlags(["-fno-finite-math-only"], .when(configuration: .release)),
                .unsafeFlags(["-w"]),    // ignore all warnings
                .unsafeFlags(["-fbracket-depth=512"]),
                
                .headerSearchPath("common"),
                .headerSearchPath("ggml/include"),
                .headerSearchPath("ggml/src"),
                .headerSearchPath("ggml/src/ggml-cpu"),
                .headerSearchPath("src")
                
            ]


var linkerSettings: [LinkerSetting] = [
                .linkedFramework("Foundation"),
                .linkedFramework("Accelerate"),
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
                .linkedFramework("MetalPerformanceShaders"),
                ]

var resources: [Resource] = [
                // .copy("tokenizers"),
                .process("ggml/src/ggml-metal/ggml-metal.metal"),  //Fixed path issue
                // .copy("metal")
            ]




let package = Package(
    name: "llama",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        //.macCatalyst(.v16),
    ],
    products: [
        // llama.cpp compiled as a separate library
        .library(
            name: "llama",
            targets: ["llama"]
        ),
    ],
    dependencies: [
        // Add any external Swift packages here if needed
    ],
    targets: [
        // 1) Target for llama.cpp (C++ code)
        .target(
            name: "llama",
            path: ".",     // alternatively the folder where the C++ files live
            sources: sources,  // defined above, includes src folder
            resources: resources,

            // Indicate where the "public" headers live. Usually this is "include" if that folder holds the main llama.h
            publicHeadersPath: "include",
            
            cSettings: cSettings,
            
            // If you have subfolders or additional includes, add them here.
            // SwiftPM will add these to the compiler's -I (include) paths.
            cxxSettings: [
                // The "include" folder is already the publicHeadersPath,
                // but you can also add ggml/include, ggml/src, etc.
                .headerSearchPath("ggml/include"),
                .headerSearchPath("ggml/src"),
                .headerSearchPath("ggml"),
                .headerSearchPath("src"),
                .headerSearchPath("common"),

                // Example define if you want to use Accelerate
                .define("SWIFT_PACKAGE"),
                .define("GGML_USE_ACCELERATE"), //, to: "1"),
                .define("GGML_BLAS_USE_ACCELERATE"), //, to: "1"),
                .define("ACCELERATE_NEW_LAPACK"),
                .define("ACCELERATE_LAPACK_ILP64"),
                .define("GGML_USE_BLAS"),
                .define("GGML_USE_LLAMAFILE"),
                .define("GGML_METAL_NDEBUG"),
//                .define("NDEBUG"),
                .define("GGML_USE_CPU"),
                .define("GGML_USE_METAL"),

                
//                .unsafeFlags(["-fno-objc-arc"]),    //Disable ARC for ggml-metal
                .unsafeFlags(["-fbracket-depth=512"]),
                .unsafeFlags(["-std=c++17"], .when(platforms: [.macOS, .iOS]))   // Force C++17 or whichever standard you need
            ],
            
            linkerSettings: linkerSettings
        )
    ],
    cxxLanguageStandard: .cxx17
)
