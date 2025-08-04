<?php
require_once __DIR__ . '/../Core/BaseController.php';
require_once __DIR__ . '/../Models/Chapter.php';
require_once __DIR__ . '/../../middleware/CacheMiddleware.php';

class ChapterController extends BaseController {
    private $chapterModel;
    
    public function __construct() {
        $this->chapterModel = new Chapter();
    }
    
    public function getAllChapters() {
        $this->validateMethod(['GET']);
        
        try {
            // Check cache first
            $cacheKey = 'all_chapters';
            $chapters = CacheMiddleware::get($cacheKey, 3600); // 1 hour cache
            
            if ($chapters === null) {
                $chapters = $this->chapterModel->getAllWithStats();
                CacheMiddleware::set($cacheKey, $chapters, 3600);
            }
            
            $this->success($chapters);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve chapters', 500);
        }
    }
    
    public function getChapter($chapterId) {
        $this->validateMethod(['GET']);
        
        if (!is_numeric($chapterId)) {
            $this->error('Invalid chapter ID', 400);
        }
        
        try {
            $chapter = $this->chapterModel->getChapterWithTests($chapterId);
            
            if (!$chapter) {
                $this->error('Chapter not found', 404);
            }
            
            $this->success($chapter);
            
        } catch (Exception $e) {
            $this->error('Failed to retrieve chapter', 500);
        }
    }
}