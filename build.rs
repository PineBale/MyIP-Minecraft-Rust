use std::process::Command;

const DEFAULT_LOCAL: &str = "local";
const DEFAULT_UNKNOWN_BRANCH: &str = "(unknown)";

#[allow(unused)]
fn main() {
    println!("cargo:rerun-if-changed=.git/HEAD");
    println!("cargo:rerun-if-changed=.git/refs/heads");

    let mut git_sha = DEFAULT_LOCAL.to_string();
    let mut git_branch = DEFAULT_UNKNOWN_BRANCH.to_string();

    let mut uncommited = false;

    git_sha = Command::new("git")
        .args(["rev-parse", "--short=9", "HEAD"])
        .output()
        .ok()
        .and_then(|output| {
            if output.status.success() {
                String::from_utf8(output.stdout).ok()
            } else {
                None
            }
        })
        .unwrap_or(DEFAULT_LOCAL.to_string())
        .trim()
        .to_string();

    if git_sha != DEFAULT_LOCAL {
        uncommited = Command::new("git")
            .args([
                "diff",
                "--quiet",
                "--ignore-space-at-eol",
                "--text",
                "src/*.rs",
                "build.rs",
                "Cargo.lock",
                "Cargo.toml",
                "Makefile",
            ])
            .output()
            .ok()
            .and_then(|output| Option::from(output.status.code().unwrap() == 1))
            .unwrap();

        if uncommited {
            println!("cargo:warning=Uncommited changes detected.");
            git_sha = DEFAULT_LOCAL.to_string();
        }

        git_branch = Command::new("git")
            .args(["rev-parse", "--abbrev-ref", "HEAD"])
            .output()
            .ok()
            .and_then(|output| {
                if output.status.success() {
                    String::from_utf8(output.stdout).ok()
                } else {
                    None
                }
            })
            .unwrap_or(DEFAULT_UNKNOWN_BRANCH.to_string())
            .trim()
            .to_string();
    }

    println!("cargo:rustc-env=MCSRVMYIP_RUST_GIT_SHA={git_sha}");
    println!("cargo:rustc-env=MCSRVMYIP_RUST_GIT_BRANCH={git_branch}");
}
