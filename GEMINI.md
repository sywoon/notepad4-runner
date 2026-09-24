# 项目协作规则与自动化流程 (Workspace Guidelines)

## 任务完成自动化规范 (Post-Task Automation)
每当完成用户的某一个具体任务（如代码编写、Bug 修复、配置调整、逆向 Patch 等）后，在向用户输出最终答复之前，**必须自动且主动执行以下两项工作**，无需用户每次额外提醒：

1. **同步对话文档 (`docs/conversation.md`)**：
   - 将当前轮次的用户提问与助手的核心回答、根因分析、修复方案及验证结论，以 `## 对话 X` 的统一规范追加同步到 `docs/conversation.md` 文件尾部。
   - 保持 UTF-8 编码与标准 Markdown 格式。

2. **提交 Git 变更 (`git commit`)**：
   - 检查当前工作区变动文件（包括代码、脚本、配置、文档及测试用例）；
   - 执行 `git add` 并按照 Conventional Commits 规范（如 `fix(...)`、`feat(...)`、`docs(...)`）生成简洁准确的 Commit Message 执行提交。
