extern crate compiletest_rs as compiletest;

use std::path::{Path, PathBuf};

fn link_flag(flag: &str, lib: &str, rel_path: &[&str]) -> String {
    let environment = match cfg!(debug_assertions) {
        true => "debug",
        false => "release"
    };

    let mut path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent().unwrap()
        .join("target")
        .join(environment);

    for component in rel_path {
        path = path.join(component);
    }

    format!("{} {}={}", flag, lib, path.display())
}

fn run_mode(mode: &'static str) {
    let mut config = compiletest::Config::default();
    let cfg_mode = mode.parse().expect("Invalid mode");

    config.mode = cfg_mode;
    config.src_base = PathBuf::from(format!("tests/{}", mode));

    let crate_path = link_flag("-L", "crate", &[]);
    let dep_path = link_flag("-L", "dependency", &["deps"]);
    let codegen_dep = link_flag("--extern", "rocket_codegen", &["deps", "librocket_codegen.dylib"]);

    config.target_rustcflags = Some([codegen_dep, dep_path, crate_path].join(" "));
    compiletest::run_tests(&config);
}

#[test]
fn compile_test() {
    run_mode("compile-fail");
    run_mode("run-pass");
}
