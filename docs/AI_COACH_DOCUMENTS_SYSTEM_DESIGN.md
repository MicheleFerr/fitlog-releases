# AI Coach Documents System - Design Document

**Version**: 1.1
**Date**: 2026-02-05
**Audience**: FitLogPro Web Developer
**Status**: ✅ Implemented (Backend Complete)

**Implementation Note**: Admin panel fully implemented on 2026-02-05 (commit 6775b05)
- Page: `/admin/ai-coach-documents`
- API Routes: GET/POST/DELETE/PUT complete
- Firestore integration with version control
- Next steps: Flutter app sync service

---

## Overview

System to manage scientific paper metadata for AI Coach. Admin uploads papers via web panel → Firebase stores metadata + links → Flutter app syncs and caches offline → AI Coach cites papers in responses.

**Key Principle**: Distribute metadata + abstracts (legal), NOT full PDF files (copyright compliant).

---

## 1. Admin Panel UI (`fitlogpro-web`)

### 1.1 Pages Required

#### **Page: `/admin/ai-coach/documents`**

Layout:
```
┌─────────────────────────────────────────────────────┐
│ AI Coach Document Library                           │
├─────────────────────────────────────────────────────┤
│ [+ Add Document]  [🔄 Sync Status]  [Search...]     │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Active Documents (8)                                │
│ ┌────────────────────────────────────────────────┐ │
│ │ ☑ Schoenfeld 2017 - Hypertrophy               │ │
│ │   Status: ✅ Cached by 1,250 users            │ │
│ │   Category: Hypertrophy                       │ │
│ │   License: CC-BY                              │ │
│ │   [Edit] [Delete]                             │ │
│ └────────────────────────────────────────────────┘ │
│ ┌────────────────────────────────────────────────┐ │
│ │ ☑ Krieger 2010 - Periodization                │ │
│ │   Status: ✅ Cached by 892 users              │ │
│ │   [Edit] [Delete]                             │ │
│ └────────────────────────────────────────────────┘ │
│                                                     │
│ Inactive (Marked for deletion)                      │
│ ┌────────────────────────────────────────────────┐ │
│ │ ☐ OldPaper 2015 (scheduled deletion)           │ │
│ │   Removed: 2 days ago                          │ │
│ │   [Restore]                                    │ │
│ └────────────────────────────────────────────────┘ │
│                                                     │
│ Version: v2.1 (Updated: 2h ago)                    │
└─────────────────────────────────────────────────────┘
```

#### **Modal: Add/Edit Document**

```
┌─────────────────────────────────────────────┐
│ Add Scientific Paper                         │
├─────────────────────────────────────────────┤
│                                             │
│ Search Method:                              │
│ ○ PubMed  ○ arXiv  ○ Manual Entry           │
│                                             │
│ [Search: "hypertrophy volume"]              │
│                                             │
│ Results:                                    │
│ • Schoenfeld (2017) - Hypertrophy Volume   │
│   DOI: 10.1234/ijspp.2017.123              │
│   Status: ✅ Open Access                   │
│   [Select]                                 │
│                                             │
│ • Krieger (2010) - Periodization           │
│   DOI: 10.1002/jbmr.456                    │
│   Status: ❌ Paywall                       │
│   (Not recommended - not open access)      │
│                                             │
│ ─── OR MANUAL ENTRY ───                    │
│                                             │
│ Title: [__________________________]         │
│ Authors: [__________________________]       │
│ Year: [____]                                │
│ DOI: [__________________________]            │
│ Abstract: [________________________]        │
│                                             │
│ Category:                                   │
│ ☑ Hypertrophy  ☑ Strength  ☐ Endurance    │
│ ☐ Programming  ☐ Recovery  ☐ Nutrition   │
│                                             │
│ License: [CC-BY / CC0 / Open Access / Other]│
│                                             │
│ URL (direct access):                        │
│ [https://doi.org/10.1234/...]              │
│                                             │
│ [Cancel] [Save]                             │
└─────────────────────────────────────────────┘
```

---

## 2. Firestore Structure

### 2.1 Collections & Documents

#### **Collection: `ai_coach_documents`**

```firestore
ai_coach_documents/
├── paper_001/
│   ├── id (string): "paper_001"
│   ├── title (string): "Hypertrophy Volume Dose Response"
│   ├── authors (array<string>): ["Schoenfeld, B.J.", "Ogborn, D.", ...]
│   ├── year (number): 2017
│   ├── doi (string): "10.1519/JSC.0000000000001627"
│   ├── abstract (string): "[Full abstract text - ~200-300 words]"
│   ├── url (string): "https://doi.org/10.1519/JSC.0000000000001627"
│   ├── license (string): "CC-BY" | "CC0" | "OpenAccess" | "Other"
│   ├── categories (array<string>): ["hypertrophy", "volume", "training"]
│   ├── keywords (array<string>): ["sets", "reps", "volume", "progression"]
│   ├── active (boolean): true
│   ├── uploadedAt (timestamp): 2026-02-05T10:30:00Z
│   ├── updatedAt (timestamp): 2026-02-05T10:30:00Z
│   ├── createdBy (string): "admin_user_id"
│   ├── summary (string): "[Short 1-2 sentence summary for AI]"
│   └── metadata (map):
│       ├── journal (string): "Journal of Strength and Conditioning Research"
│       ├── volume (number): 31
│       ├── issue (number): 7
│       └── pages (string): "1831-1847"
│
├── paper_002/
│   ├── [same structure]
│   └── ...
```

#### **Document: `_metadata` (collection root)**

```firestore
ai_coach_documents/_metadata/
├── version (string): "v2.1"
├── lastUpdated (timestamp): 2026-02-05T10:30:00Z
├── totalDocuments (number): 8
├── activeDocuments (number): 8
├── hash (string): "abc123def456xyz789" (SHA-256 of all active docs)
├── syncChecksum (string): "[for app validation]"
└── categories (map):
    ├── hypertrophy (number): 3
    ├── strength (number): 2
    ├── endurance (number): 1
    ├── programming (number): 1
    └── recovery (number): 1
```

---

## 3. Backend API Endpoints (Web)

### 3.1 Admin Endpoints

#### **POST `/api/admin/documents`** - Add Document

```javascript
Request:
{
  "title": "Hypertrophy Volume Dose Response",
  "authors": ["Schoenfeld, B.J.", "Ogborn, D."],
  "year": 2017,
  "doi": "10.1519/JSC.0000000000001627",
  "abstract": "[Full text]",
  "url": "https://doi.org/10.1519/JSC.0000000000001627",
  "license": "CC-BY",
  "categories": ["hypertrophy", "volume"],
  "keywords": ["sets", "reps", "volume"],
  "summary": "Study on optimal volume for muscle growth",
  "metadata": {
    "journal": "Journal of Strength and Conditioning Research",
    "volume": 31,
    "issue": 7,
    "pages": "1831-1847"
  }
}

Response:
{
  "success": true,
  "documentId": "paper_001",
  "createdAt": "2026-02-05T10:30:00Z",
  "message": "Document added. Version bumped to v2.1"
}
```

#### **PUT `/api/admin/documents/:docId`** - Update Document

```javascript
Request:
{
  "title": "[updated title]",
  "active": true,
  // ... other fields
}

Response:
{
  "success": true,
  "documentId": "paper_001",
  "versionBumped": "v2.2",
  "message": "Document updated. Apps will sync within 1 hour."
}
```

#### **DELETE `/api/admin/documents/:docId`** - Delete Document

```javascript
Response:
{
  "success": true,
  "documentId": "paper_001",
  "markedForDeletion": true,
  "versionBumped": "v2.3",
  "message": "Document marked inactive. Apps will remove within 24h."
}
```

#### **GET `/api/admin/documents/search`** - Search External APIs

```javascript
Query: ?query=hypertrophy&source=pubmed

Response:
{
  "results": [
    {
      "source": "pubmed",
      "pmid": "27328285",
      "title": "Hypertrophy Volume Dose Response",
      "authors": ["Schoenfeld, B.J."],
      "year": 2017,
      "doi": "10.1519/JSC.0000000000001627",
      "abstract": "[text]",
      "openAccess": true,
      "url": "https://doi.org/...",
      "suggestedLicense": "CC-BY"
    }
    // ... more results
  ]
}
```

---

## 4. Flutter App Integration Points

### 4.1 API Endpoints (App will call)

#### **GET `/api/v1/ai-coach/documents/metadata`** - Check for updates

```javascript
Request Headers:
{
  "Authorization": "Bearer [user_token]",
  "X-App-Version": "1.2.3",
  "X-Local-Version": "v2.0"
}

Response:
{
  "version": "v2.1",
  "hash": "abc123def456xyz789",
  "documentsCount": 8,
  "documentsToAdd": [
    {
      "id": "paper_003",
      "title": "...",
      "url": "https://storage.googleapis.com/...",
      "size": 450000,
      "hash": "xyz789abc123def456"
    }
  ],
  "documentsToRemove": ["paper_001"],
  "lastUpdated": "2026-02-05T10:30:00Z"
}
```

#### **GET `/api/v1/ai-coach/documents/:docId/metadata`** - Get paper details (for AI)

```javascript
Response:
{
  "id": "paper_001",
  "title": "Hypertrophy Volume Dose Response",
  "authors": ["Schoenfeld, B.J.", "Ogborn, D."],
  "year": 2017,
  "doi": "10.1519/JSC.0000000000001627",
  "abstract": "[Full abstract]",
  "summary": "[Short summary]",
  "url": "https://doi.org/10.1519/JSC.0000000000001627",
  "categories": ["hypertrophy", "volume"],
  "keywords": ["sets", "reps", "volume", "progression"]
}
```

---

## 5. Data Flow

### 5.1 Upload Flow (Admin → Firebase)

```
Admin Panel
    ↓
[Search PubMed / Manual Entry]
    ↓
[Validate: Open Access? License OK?]
    ↓
Firestore: Create document
Firestore: Update ai_coach_documents/_metadata
    ↓
Increment version (v2.0 → v2.1)
    ↓
Update hash/checksum
    ↓
✅ Document live (apps will detect in next sync)
```

### 5.2 Sync Flow (App → Firebase)

```
App (daily background task)
    ↓
GET /api/v1/ai-coach/documents/metadata
    ↓
Compare: local version vs server version
    ↓
IF different:
  - Fetch list of documents to add/remove
  - Download new papers (metadata only)
  - Delete removed papers
  - Update local cache
  - Persist new version
    ↓
IF same:
  - Skip (zero network)
    ↓
✅ Sync complete
```

---

## 6. Implementation Checklist

### Backend (Web)

- [ ] Firestore collections setup (`ai_coach_documents`, `_metadata`)
- [ ] Admin CRUD endpoints (`POST`, `PUT`, `DELETE`)
- [ ] PubMed API integration (search + fetch metadata)
- [ ] arXiv API integration (optional)
- [ ] CrossRef API integration (DOI resolution)
- [ ] Version bumping logic
- [ ] Hash generation (SHA-256)
- [ ] Document validation (open access check)
- [ ] Error handling + logging

### Frontend (Admin Panel)

- [ ] Documents list page
- [ ] Add/Edit modal
- [ ] Search integration (PubMed search)
- [ ] Category selection
- [ ] License validation UI
- [ ] Sync status display
- [ ] Delete confirmation

### App (Flutter) - *[Handled separately in app design]*

- [ ] Background sync service
- [ ] Metadata cache (Hive)
- [ ] PDF download queue
- [ ] Hash verification
- [ ] AI Coach integration (retrieval)

---

## 7. Technical Notes

### 7.1 External APIs

**PubMed API**
- Free tier: 3 requests/second
- Docs: https://www.ncbi.nlm.nih.gov/books/NBK25497/
- Returns: XML (parse to JSON)

**CrossRef API**
- Free tier: Unlimited
- Docs: https://www.crossref.org/documentation/retrieval-api/
- Returns: JSON

**arXiv API** (optional)
- Free: Unlimited
- Docs: https://arxiv.org/help/api

### 7.2 Copyright Compliance

- ✅ Abstract distribution: Legal (covered by fair use + CC licenses)
- ✅ Metadata distribution: Always legal
- ✅ Links to full text: Legal (just links)
- ❌ Full PDF distribution: Illegal (unless paper is CC0 or author permits)

**Validate before adding**: Check `openAccess` flag + license type.

### 7.3 Performance Notes

- Metadata per paper: ~5-10KB
- 100 papers = ~500KB-1MB (negligible)
- Sync frequency: Daily (configurable)
- Version comparison: Fast (simple string compare)

---

## 8. Example Deployment

### Initial Dataset (Suggested)

Start with 8-10 canonical papers:

1. **Schoenfeld (2017)** - Hypertrophy Volume
   - DOI: 10.1519/JSC.0000000000001627
   - License: CC-BY ✅

2. **Krieger (2010)** - Single vs Multiple Sets
   - DOI: 10.1519/JSC.0b013e3181d98287
   - License: CC-BY ✅

3. **Haun et al. (2019)** - Isolated vs Compound
   - DOI: 10.1186/s12970-019-0308-5
   - License: CC-BY ✅

[... add 5-7 more canonical papers]

---

## 9. Success Criteria

- ✅ Admin can upload papers in <2 minutes
- ✅ Apps sync automatically without user action
- ✅ Zero copyright violations
- ✅ Papers searchable by category + keywords
- ✅ AI Coach cites papers with links
- ✅ Version tracking works (no stale papers)
- ✅ Performance: Sync completes <5 seconds

---

## 10. Future Enhancements

- [ ] Paper rating system (thumbs up/down)
- [ ] User annotation system
- [ ] Paper recommendations based on user profile
- [ ] Academic credit system (citations count toward achievement badges)
- [ ] Auto-fetch from journals (RSS feeds)

---

**Questions? Contact FitLog Team or AI Coach Product Lead.**
