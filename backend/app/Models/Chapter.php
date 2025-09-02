<?php
require_once __DIR__ . '/../Core/BaseModel.php';

class Chapter extends BaseModel {
    protected $table = 'chapters';
    protected $fillable = ['chapter_number', 'name', 'description'];
    
    public function __construct() {
        parent::__construct();
    }
    
    public function getAllWithStats() {
        $sql = "SELECT c.*, 
                       COUNT(t.id) as total_tests
                FROM {$this->table} c
                LEFT JOIN tests t ON c.id = t.chapter_id
                GROUP BY c.id
                ORDER BY c.chapter_number";
        
        return $this->query($sql);
    }
    
    public function getChapterWithTests($chapterId) {
        $chapter = $this->find($chapterId);
        
        if ($chapter) {
            $tests = $this->query(
                "SELECT * FROM tests WHERE chapter_id = :chapter_id ORDER BY test_number",
                [':chapter_id' => $chapterId]
            );
            $chapter['tests'] = $tests;
        }
        
        return $chapter;
    }
}