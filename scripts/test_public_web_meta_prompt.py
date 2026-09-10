#!/usr/bin/env python3
"""Static contract test for the public zero-barrier T1–T9 Web prompt."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROMPT = ROOT / "prompts/web/ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md"
MANIFEST = ROOT / "prompts/web/publication-manifest.v1.json"


def main() -> int:
    text = PROMPT.read_text(encoding="utf-8")
    start = text.index("## 5. 可直接复制的最终系统提示词")
    end = text.index("## 6. 首轮输出验收清单", start)
    blocks = re.findall(r"```text\n(.*?)\n```", text[start:end], flags=re.DOTALL)
    assert len(blocks) == 1, f"expected one final prompt source block, got {len(blocks)}"
    prompt = blocks[0]
    required = (
        "第一次回复只能包含恰好九个 Markdown 代码块",
        "T1、T2、T3、T4、T5、T6、T7、T8、T9",
        "不输出 BLOCK、BLOCK_PRE_ADMISSION、NOT_RUNNABLE",
        "target × effect × output",
        "43 个 documented child subdirections",
        "propagation=none",
        "verifier-side trusted challenge",
        "potentially malicious",
        "trusted typed probe",
        "trusted_fixture_native",
        "leanchecker --fresh",
        "sandbox-external",
        "counterexample_check + statement_identity + statement_faithfulness",
        "EXPECTED ARTIFACT",
        "现在静默读取目标仓库",
    )
    missing = [value for value in required if value not in prompt]
    assert not missing, f"missing public Web prompt contract: {missing}"
    assert "MODE=COORDINATOR" not in prompt
    assert all(f"T{index}＝" in prompt for index in range(1, 10))
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert manifest["prompt_version"] == "0.3.0"
    assert manifest["prompt_path"] == PROMPT.relative_to(ROOT).as_posix()
    assert manifest["prompt_sha256"] == hashlib.sha256(PROMPT.read_bytes()).hexdigest()
    assert manifest["source_status"] == "validated_public_source"
    assert manifest["release_status"] == "ready_for_pr_review"
    assert not any(manifest["capability_claims"].values())
    print("public Web meta-prompt contract: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
