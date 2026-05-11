---
name: lamont-ir-research-methods
description: Use when designing, planning, or writing up an IR research project using Christopher Lamont's *Research Methods in International Relations* (2nd ed., SAGE 2022) — positioning epistemology (positivist / post-positivist / interpretivist / critical), framing a research puzzle and question, building a literature review matrix, drafting a research design, justifying case selection (Mill's methods, typical/deviant/most-similar/most-different), choosing between qualitative / quantitative / mixed methods, completing a research-ethics checklist, or outlining a paper for an IR journal. Ships 8 fill-in templates aligned to Lamont's pipeline.
---

# Lamont IR Research Methods

A templates-driven companion for IR researchers (PhD and Master's students) following the research workflow in Christopher Lamont, *Research Methods in International Relations* (2nd ed., SAGE Publications, 2022). The skill paraphrases and operationalizes Lamont's framework — it does **not** redistribute the book's text. Scholars should own or borrow a copy.

**Core principle:** every template names the Lamont chapter (by topic) it draws on. Page numbers and exact chapter numbers vary by printing — consult your own copy for precise references when you cite the book.

## When to use

- Drafting a research question for an IR thesis, dissertation, or journal article
- Justifying a research design to a supervisor, reviewer, or IRB
- Choosing and defending case selection in a comparative study
- Deciding between qualitative, quantitative, and mixed-methods approaches
- Preparing a research-ethics statement for human-subjects work in IR (interviews, ethnography, sensitive populations)
- Outlining a paper structure for submission to an IR journal

**Do not use** for:

- A substitute for reading Lamont — the templates point you back to the book; the book contains the theoretical grounding the templates compress
- Methodologies outside Lamont's scope (e.g., formal modelling, computational text analysis, experimental designs in political science) — those require their own references
- Non-IR research designs where the discipline-specific framing in Lamont does not transfer

## The pipeline

Eight templates, one per stage. The numbering is the recommended order; in practice you will iterate (e.g., refine the research question after the lit review).

| Stage | Template | Lamont chapter (topic) |
|-------|----------|------------------------|
| Position your epistemology | `templates/01_epistemology_brief.md` | Knowledge and research in IR |
| Frame a research puzzle and question | `templates/02_research_question.md` | Research questions and puzzles |
| Map the existing literature | `templates/03_lit_review_matrix.md` | The literature review |
| Draft the research design | `templates/04_research_design.md` | Research design |
| Justify case selection | `templates/05_case_selection_matrix.md` | Case study methods |
| Justify the method (qual / quant / mixed) | `templates/06_methods_justification.md` | Qualitative, quantitative, and mixed methods |
| Complete the ethics checklist | `templates/07_ethics_checklist.md` | Research ethics |
| Outline the write-up | `templates/08_writeup_outline.md` | Writing up |

## How to use the templates

1. Copy a template into your working project (e.g., into `docs/design/` of your thesis repo or a Notion/Google Doc).
2. Replace every `[fill in: …]` placeholder with your own content. The bracketed prompt tells you what the section asks for.
3. Tick the checklist at the bottom of each template before treating that stage as settled.
4. Cite Lamont in your methods section whenever a template's framing materially shaped your design (e.g., the case-selection logic, the qual/quant/mixed justification).
5. Keep the filled-in templates alongside your draft — they are the auditable trail of your design decisions for supervisors and reviewers.

Placeholders use the literal string `[fill in: …]` so you can grep your filled drafts (`grep -r "fill in:" .`) to find anything you forgot.

## Pairing with the COW Arms Technology skill

If your project uses the *Correlates of War Arms Technology Dataset v1.0* (or another COW dataset), fill in templates `04_research_design.md` and `06_methods_justification.md` **before** opening the data. The arms-tech skill (`skills/cow-arms-technology-analysis/`) is built around publication-ready data work — `total_use` trajectories, leap-frog detection, COW state-system continuity. The Lamont skill is built around the design questions that decide whether and how you should use that data in the first place. The two are independent; use them in sequence.

## Citation

When the framework or templates here materially shaped your analytical decisions, cite Lamont:

> Lamont, C. (2022). *Research Methods in International Relations* (2nd ed.). SAGE Publications.

For the skill collection itself (optional, in a footnote):

> Molinas, E. (2026). *Correlates of War Skills: lamont-ir-research-methods*. GitHub repository: https://github.com/estanimolinas/correlationsofwarskills.

## Scope and limits

- The templates **paraphrase** Lamont's framework under fair-use academic citation. They are not a replacement for the book; the book contains the philosophical context (positivism vs. interpretivism, the place of critical theory in IR, the limits of each method) that the templates compress into prompts.
- Page numbers and exact chapter numbers are intentionally **not** included — they vary by printing. Cite the chapter topic when paraphrasing; consult your own copy for precise references.
- The skill is opinionated about IR: the templates assume a state-centric or transnational framing common to peer-reviewed IR journals. Adapt the prompts for area-studies, comparative-politics, or peace-studies framings as needed.

## Feedback

Found a template prompt that doesn't translate well to your sub-field, or a Lamont chapter the skill should cover more fully? Open a GitHub issue at the repo (https://github.com/estanimolinas/correlationsofwarskills).
