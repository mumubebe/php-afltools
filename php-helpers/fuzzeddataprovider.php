<?php

class FuzzedDataProvider {
    private string $data;
    private int $pos = 0;

    public function __construct(string $data) {
        $this->data = $data;
    }

    public function remainingBytes(): int {
        return strlen($this->data) - $this->pos;
    }

    public function consumeBytes(int $num): string {
        $num = min($num, $this->remainingBytes());
        $chunk = substr($this->data, $this->pos, $num);
        $this->pos += $num;
        return $chunk;
    }

    public function consumeBool(): bool {
        $byte = $this->consumeBytes(1);
        return strlen($byte) > 0 ? (ord($byte[0]) % 2 === 1) : false;
    }

    public function consumeInt(int $min, int $max): int {
        if ($min > $max) {
            throw new InvalidArgumentException("min must be <= max");
        }

        $range = $max - $min;
        $bytes = $this->consumeBytes(4);
        $value = 0;

        for ($i = 0; $i < strlen($bytes); $i++) {
            $value |= ord($bytes[$i]) << ($i * 8);
        }

        if ($range == 0) return $min;
        return $min + ($value % ($range + 1));
    }

    public function consumeUntil(string $pattern, bool $consumeRemainingIfNotFound = true): string {
        if ($pattern === '') {
            throw new InvalidArgumentException("Pattern cannot be empty");
        }
    
        $offset = strpos($this->data, $pattern, $this->pos);
    
        if ($offset === false) {
            if ($consumeRemainingIfNotFound) {
                return $this->consumeRemainingAsString();
            } else {
                return '';
            }
        }
    
        $length = $offset - $this->pos;
        return $this->consumeBytes($length);
    }

    public function consumeByte(): int {
        $byte = $this->consumeBytes(1);
        return strlen($byte) > 0 ? ord($byte[0]) : 0;
    }

    public function consumeString(int $maxLength): string {
        $length = $this->consumeInt(0, $maxLength);
        return $this->consumeBytes($length);
    }

    public function consumeRemainingAsString(): string {
        return $this->consumeBytes($this->remainingBytes());
    }
}
